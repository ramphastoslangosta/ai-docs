# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an **AI-powered task management and code review system** built around Claude Code slash commands and agents. The system provides a structured workflow for analyzing codebases, generating development tasks, creating atomic execution plans, and tracking implementation progress.

**Primary Use Case**: Transform code review findings into actionable, tracked development work with atomic commit strategies and comprehensive documentation.

## Architecture

### Core Workflow Pattern

```
/code-review → /generate_tasks → /atomic-plan → /execute-task
     ↓              ↓                 ↓              ↓
  Analysis      Task CSV          Workspace      Implementation
```

**Three-Tier Structure**:

1. **Commands** (`commands/`) - Slash command definitions that orchestrate workflows
2. **Agents** (`agents/`) - Specialized AI agents invoked by commands for complex analysis
3. **Workspace** (`workspace/`) - Task-specific execution environments with plans, checklists, and notes

### Key Components

**Agents** (`agents/`):
- `code-reviewer-architect.md` - Performs comprehensive code analysis, identifies technical debt, generates refactoring recommendations with OWASP/SOLID compliance checks
- `task-package-generator.md` - Transforms code review findings into structured task packages (tasks.csv, git workflows, PR templates, test scaffolds, progress dashboards)

**Commands** (`commands/`):
- `code-review.md` - Invokes code-reviewer-architect agent, generates analysis reports to `docs/code-review-reports/`
- `generate_tasks.md` - Invokes task-package-generator agent, creates tasks.csv with git branches and PR templates
- `atomic-plan.md` - Creates detailed step-by-step execution plans for specific tasks with test checkpoints and rollback procedures
- `execute-task.md` - Implements atomic plan steps one at a time, running tests and committing changes
- `prime.md` - Quick codebase orientation command for FastAPI window quotation system (example/template)

**Workspace Structure** (`workspace/TASK-ID/`):
Each task gets an isolated workspace containing:
- `atomic-plan-{TASK_ID}.md` - Detailed implementation steps with code, commands, test checkpoints
- `checklist-{TASK_ID}.md` - Progress tracker with `[ ]` and `[x]` items
- `README.md` - Quick reference, success criteria, troubleshooting
- `notes.md` - Session log with timestamps and observations

## Task Tracking System

**tasks.csv Format**:
```csv
task_id,title,description,priority,status,phase,estimated_effort,dependencies,branch_name,pr_template,test_file,notes
```

**Task ID Patterns**:
- `TASK-YYYYMMDD-NNN` - General development tasks
- `ARCH-YYYYMMDD-NNN` - Architecture refactoring
- `HOTFIX-YYYYMMDD-NNN` - Emergency fixes
- `PROCESS-YYYYMMDD-NNN` - Process improvements
- `MTENANT-YYYYMMDD-NNN` - Multi-tenant features
- `DEVOPS-YYYYMMDD-NNN` - DevOps/deployment tasks

**Status Values**: `pending`, `in-progress`, `completed`, `blocked`

**Priority Values**: `critical`, `high`, `medium`, `low`

## Common Workflows

### Code Review to Task Execution

```bash
# 1. Analyze codebase
/code-review full

# 2. Generate tasks from review
/generate_tasks

# 3. Create execution plan for first task
/atomic-plan TASK-20250929-001

# 4. Execute plan step-by-step
/execute-task TASK-20250929-001
```

### Working with Tasks

```bash
# View pending tasks
grep ",pending," tasks.csv

# View critical tasks
grep ",critical," tasks.csv | grep ",pending,"

# Update task status to in-progress
sed -i '' "s/TASK-ID,\([^,]*\),pending,/TASK-ID,\1,in-progress,/" tasks.csv

# Mark task completed
sed -i '' "s/TASK-ID,\([^,]*\),[^,]*,/TASK-ID,\1,completed,/" tasks.csv
```

### Workspace Management

```bash
# List all workspaces with status
/list-workspaces

# List only active workspaces
/list-workspaces active

# Archive a completed workspace
/archive-workspace TASK-ID

# Clean up abandoned workspaces (preview first)
/cleanup-workspaces --dry-run
/cleanup-workspaces

# Manual check: View workspace structure
ls -la workspace/TASK-ID/

# Manual check: Check progress
grep "\[x\]" workspace/TASK-ID/checklist-TASK-ID.md | wc -l  # Completed
grep "\[ \]" workspace/TASK-ID/checklist-TASK-ID.md | wc -l  # Remaining
```

## Atomic Plan Execution Protocol

When executing tasks via `/execute-task`, follow this critical sequence:

1. **Read workspace files** (atomic-plan, checklist, notes)
2. **Identify next pending step** from checklist
3. **Execute implementation** following plan exactly
4. **Run test checkpoint** (MANDATORY - stop if fails)
5. **Verify success** against expected output
6. **Commit changes** with message from plan
7. **Update documentation** (checklist, notes, README)
8. **Commit documentation** separately
9. **Report completion** and wait for next instruction

**Critical Rules**:
- Never skip test checkpoints
- Stop immediately if tests fail (no commits, no progression)
- Follow plan exactly - don't improvise
- One step at a time unless explicitly batched
- Update checklist and notes after each step

## Configuration

**Settings** (`settings.local.json`):
```json
{
  "permissions": {
    "allow": [
      "Bash(ssh:*)",
      "Bash(pip install:*)",
      "Bash(export:*)",
      "Bash(pytest:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(cat:*)"
    ]
  }
}
```

## Code Review Report Structure

Reports generated to: `docs/code-review-reports/code-review-agent_YYYY-MM-DD-HH.md`

**Report Sections**:
- Executive Summary (health score, critical issues, immediate actions)
- Detailed Analysis (code quality, architecture, performance, security)
- Refactoring Roadmap (phased approach with atomic commits)
- Git Workflow & Implementation Guide
- Risk Management & Rollback Procedures
- Success Metrics & Monitoring

**Analysis Framework**:
1. **Code Quality**: Cyclomatic complexity (>10 flagged), duplication (>5 lines), naming, function size, error handling
2. **Architecture**: SOLID principles, design patterns, coupling, separation of concerns
3. **Performance**: Bottlenecks, algorithm efficiency, database optimization, caching
4. **Security**: OWASP Top 10, input validation, authentication/authorization, SQL injection, XSS

## Task Package Generation

Invoked by `/generate_tasks`, creates:

1. **tasks.csv updates** - Structured task entries with dependencies
2. **Git branch scaffolds** - Scripts in `scripts/branches/create-phase-N-branches.sh`
3. **PR templates** - Category-specific templates in `.github/pull_request_template/`
4. **Test scaffolds** - Empty test files with TODO structure
5. **Progress dashboard** - Interactive HTML at `docs/task-dashboards/refactoring-progress-{timestamp}.html`

**Branch Naming Convention**: `{type}/{scope}-{date}`
- Examples: `security/sql-injection-fix-20250929`, `performance/optimization-20250929`, `refactor/architecture-20250929`

## Best Practices

### Planning
- Review atomic plan completely before starting
- Understand all steps and their dependencies
- Check success criteria and test checkpoints
- Verify branch and rollback procedures

### Execution
- Execute one atomic step at a time
- Run test checkpoint after each step
- Commit after each successful step
- Update checklist and notes immediately
- Document any deviations from plan

### Testing
- All test checkpoints are mandatory
- Never skip tests to "fix later"
- Stop execution immediately if tests fail
- Analyze root cause before proceeding
- Update plan if tests reveal issues

### Documentation
- Keep notes.md updated with timestamps
- Mark checklist items as completed promptly
- Record actual vs. estimated time
- Document issues and resolutions
- Update README progress metrics

### Git Workflow
- Use atomic commits (one feature/fix per commit)
- Follow commit message format from plan
- Separate implementation and documentation commits
- Never force push to main/master
- Create feature branches from main

### Workspace Management
- List workspaces regularly to monitor active work
- Archive completed workspaces promptly (keeps workspace/ directory clean)
- Review stale workspaces weekly (>7 days without updates)
- Clean up abandoned workspaces monthly (>30 days old with low progress)
- Always use --dry-run before cleanup operations
- Backups are created automatically before cleanup

## Workspace Management Commands

### /list-workspaces [status]

List all task workspaces with status, progress, and activity metrics.

**Status filters**:
- `active` - Recently modified workspaces with in-progress tasks (1-99%, <7 days)
- `completed` - Workspaces with 100% checklist completion
- `stale` - Workspaces with progress but no recent activity (7-30 days)
- `abandoned` - Workspaces with no activity for >30 days
- `all` - Show all workspaces (default)

**Examples**:
```bash
# List all workspaces
/list-workspaces

# List only active work
/list-workspaces active

# Find workspaces ready for archival
/list-workspaces completed
```

**Output**: Summary statistics, workspace table with progress percentages, last modified dates, and recommended actions.

### /archive-workspace TASK-ID

Archive a completed workspace to preserve history while cleaning up the active workspace directory.

**Process**:
1. Validates workspace exists and checks completion status
2. Prompts for confirmation if workspace is not 100% complete
3. Commits any uncommitted changes to git (if in repo)
4. Creates archive metadata with workspace statistics
5. Moves workspace to `workspace/archive/TASK-ID-completed-{timestamp}/`
6. Updates `tasks.csv` status to "archived" (if file exists)
7. Updates archive index for tracking

**Examples**:
```bash
# Archive a completed workspace
/archive-workspace TASK-20250929-012

# Archive even if incomplete (will prompt)
/archive-workspace HOTFIX-20251006-001
```

**Archive structure**:
```
workspace/archive/
├── ARCHIVE_INDEX.md
└── TASK-20250929-012-completed-20251008-143022/
    ├── ARCHIVE_METADATA.txt
    ├── atomic-plan-TASK-20250929-012.md
    ├── checklist-TASK-20250929-012.md
    ├── notes.md
    └── README.md
```

**Restoration**: `mv workspace/archive/TASK-ID-completed-{timestamp} workspace/TASK-ID`

### /cleanup-workspaces [--dry-run] [--days N] [--force]

Automatically clean up abandoned workspaces based on age and activity thresholds.

**Options**:
- `--dry-run` - Preview what would be deleted without executing (recommended first)
- `--days N` - Age threshold in days (default: 30)
- `--progress-threshold N` - Minimum progress % to keep (default: 10%)
- `--force` - Skip confirmation prompt

**Cleanup criteria**:
- **Abandoned**: >30 days old AND <10% progress
- **Empty**: 0% progress AND >7 days old
- **Protected**: Completed workspaces (100%) are never deleted, archive them instead
- **Protected**: Stale workspaces with ≥10% progress require manual review

**Safety features**:
- Automatic backup to `workspace/.cleanup-backup/cleanup-{timestamp}/`
- Deletion manifest with restoration commands
- Confirmation prompt (unless --force)
- Updates tasks.csv with "deleted" status
- Backup retention: 90 days

**Examples**:
```bash
# Preview cleanup (recommended first)
/cleanup-workspaces --dry-run

# Execute cleanup with defaults (30 days, 10% progress)
/cleanup-workspaces

# More aggressive cleanup (14 days)
/cleanup-workspaces --days 14

# Non-interactive cleanup for automation
/cleanup-workspaces --force
```

**Restoration**:
```bash
# View cleanup backups
ls workspace/.cleanup-backup/

# Restore specific workspace
cp -R workspace/.cleanup-backup/cleanup-{timestamp}/TASK-ID workspace/
```

## Workspace Management Workflows

### Daily Workflow
```bash
# Morning: Check active work
/list-workspaces active

# Execute tasks
/execute-task TASK-ID
```

### Weekly Maintenance
```bash
# List all workspaces
/list-workspaces

# Archive completed workspaces
/list-workspaces completed  # Review list
/archive-workspace TASK-ID  # Archive each one

# Review stale workspaces (manual)
/list-workspaces stale
```

### Monthly Cleanup
```bash
# Preview cleanup candidates
/cleanup-workspaces --dry-run

# Review and execute
/cleanup-workspaces

# Verify clean state
/list-workspaces
```

### Sprint End Routine
```bash
# 1. Archive all completed work
for TASK in $(ls workspace/ | grep -v archive); do
    /list-workspaces $TASK | grep -q "Complete" && /archive-workspace $TASK
done

# 2. Clean up abandoned work
/cleanup-workspaces

# 3. Review remaining active work
/list-workspaces active
```

## Integration Points

**Git Integration**:
- Branch scaffolding scripts auto-generate git commands
- Commit messages templated in atomic plans
- PR templates linked to task categories

**Testing Integration**:
- Test checkpoints embedded in atomic plans
- Test scaffolds created per task
- Coverage requirements in success criteria

**Progress Tracking**:
- HTML dashboards render from tasks.csv
- Real-time filtering by status/priority/phase
- Dependency visualization
- Velocity and burndown tracking

## Troubleshooting

### Task Not Found in tasks.csv
```bash
# List available tasks
cat tasks.csv | column -t -s','

# Search by keyword
grep -i "keyword" tasks.csv
```

### Workspace Already Exists
```bash
# Archive old workspace
mkdir -p workspace/archive
mv workspace/TASK-ID workspace/archive/TASK-ID-$(date +%Y%m%d-%H%M%S)

# Regenerate plan
/atomic-plan TASK-ID
```

### Test Checkpoint Fails
```bash
# DO NOT proceed to next step
# DO NOT commit changes
# Analyze error output
# Fix root cause
# Rerun test checkpoint
# Only proceed after passing
```

### Dependencies Not Met
```bash
# Check dependency status
DEPS=$(grep "^TASK-ID," tasks.csv | cut -d',' -f8)
for DEP in $(echo "$DEPS" | tr ',' ' '); do
    grep "^$DEP," tasks.csv
done

# Complete dependencies first or override if acceptable
```

## Notes

- This system is designed for structured, methodical development with comprehensive tracking
- All workflows emphasize atomic commits, test-driven development, and detailed documentation
- The workspace pattern ensures each task has complete context and execution history
- Progress dashboards and metrics enable team visibility and velocity tracking
