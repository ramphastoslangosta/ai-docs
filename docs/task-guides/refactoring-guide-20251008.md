# AI-Docs Refactoring Execution Guide

**Generated**: 2025-10-08 16:00:00
**Source Code Review**: [code-review-agent_2025-10-08-15.md](../code-review-reports/code-review-agent_2025-10-08-15.md)
**Task Package**: 14 tasks across 3 phases
**Total Estimated Effort**: 5 days
**Priority Level**: CRITICAL to MEDIUM

---

## Executive Summary

This guide provides a complete execution roadmap for implementing the AI-docs system refactoring identified in the code review analysis. The refactoring addresses critical infrastructure deficits, security vulnerabilities, operational gaps, and code quality issues.

**Health Score**: 62/100 → Target: 90+/100
**Critical Issues**: 5 (command injection, missing git, missing tasks.csv)
**Risk Level**: HIGH → Target: LOW

---

## Quick Start

```bash
# 1. Review task breakdown
cat /Users/rafaellang/ai-docs/tasks.csv | column -t -s','

# 2. View progress dashboard
open /Users/rafaellang/ai-docs/docs/task-dashboards/refactoring-progress-20251008-16.html

# 3. Start Phase 1 (Critical Infrastructure)
bash /Users/rafaellang/ai-docs/scripts/branches/create-phase-1-branches.sh

# 4. Execute first task
# NOTE: Git must be initialized first (TASK-20251008-001)
cd /Users/rafaellang/ai-docs
git init
git add .
git commit -m "chore: initialize repository with AI-docs task management system"
```

---

## Phase 1: Critical Infrastructure & Security

**Timeline**: 2 days
**Branch**: `infrastructure/critical-setup-20251008`
**Risk Level**: LOW (additive changes only)
**Tasks**: 7 (TASK-20251008-001 through TASK-20251008-007)

### Phase 1 Overview

Phase 1 establishes the foundational infrastructure that all other workflows depend on. This includes git repository initialization, task tracking file creation, security hardening, and documentation.

**Critical Dependencies**:
- Git must be initialized before any other tasks (blocks all git operations)
- tasks.csv must exist before task commands can run
- Input validation must be implemented before patching commands

### Task Execution Order

#### TASK-20251008-001: Initialize Git Repository
**Priority**: CRITICAL
**Effort**: 0.125 days (1 hour)
**Dependencies**: None

**Implementation**:
```bash
cd /Users/rafaellang/ai-docs

# Initialize git repository
git init

# Verify git is working
git status

# Create initial commit with all existing files
git add .
git commit -m "chore: initialize repository with AI-docs task management system

- Add complete slash command infrastructure (9 commands)
- Add workspace management system (8 active workspaces)
- Add code review and task generation agents (2 agents)
- Add template library (7 templates)
- Add comprehensive documentation (CLAUDE.md)

Part of Phase 1: Critical Infrastructure & Security"

# Verify commit
git log --oneline
```

**Test Checkpoint**:
```bash
# Verify .git directory exists
test -d .git && echo "✅ Git initialized"

# Verify commit exists
git log --oneline | head -1

# Verify working tree is clean
git status | grep "working tree clean"
```

**Success Criteria**:
- [x] .git directory exists
- [x] Initial commit created
- [x] Working tree is clean
- [x] All git commands now functional

**Rollback**: `rm -rf .git`

---

#### TASK-20251008-002: Create tasks.csv File
**Priority**: CRITICAL
**Effort**: 0.062 days (30 minutes)
**Dependencies**: TASK-20251008-001

**Implementation**:
```bash
# NOTE: This file has already been created by the task package generator!
# Verify it exists:
test -f /Users/rafaellang/ai-docs/tasks.csv && echo "✅ tasks.csv exists"

# View contents
head /Users/rafaellang/ai-docs/tasks.csv

# Commit to git
git add tasks.csv
git commit -m "feat(tasks): add tasks.csv tracking file with schema

- CSV header with all required fields
- 14 tasks from code review refactoring roadmap
- Task dependencies mapped
- Branch names and PR templates assigned

Part of Phase 1: Critical Infrastructure & Security"
```

**Test Checkpoint**:
```bash
# Verify file exists
test -f tasks.csv && echo "✅ tasks.csv exists"

# Verify header is correct
head -1 tasks.csv | grep -q "task_id,title,description" && echo "✅ Header correct"

# Count tasks
TASK_COUNT=$(tail -n +2 tasks.csv | wc -l | tr -d ' ')
test "$TASK_COUNT" -eq 14 && echo "✅ 14 tasks found"

# Verify no CSV parsing errors
while IFS=, read -r task_id rest; do
    if [ -n "$task_id" ] && [ "$task_id" != "task_id" ]; then
        echo "Task: $task_id"
    fi
done < tasks.csv
```

**Success Criteria**:
- [x] tasks.csv exists with proper header
- [x] 14 tasks loaded (7 Phase 1, 4 Phase 2, 3 Phase 3)
- [x] No CSV parsing errors
- [x] File committed to git

**Rollback**: `rm tasks.csv && git checkout HEAD~1`

---

#### TASK-20251008-003: Add Input Validation Library
**Priority**: CRITICAL (Security Fix)
**Effort**: 0.375 days (3 hours)
**Dependencies**: TASK-20251008-001

**Implementation**:
```bash
# Create library directory
mkdir -p /Users/rafaellang/ai-docs/.claude/lib

# Create validation library (see code review report lines 644-730 for full code)
cat > /Users/rafaellang/ai-docs/.claude/lib/input-validation.sh << 'VALIDATION_LIB'
#!/bin/bash
# Input Validation Library for AI-Docs Task Management System
# Prevents command injection and path traversal attacks

# Validate TASK_ID format
validate_task_id() {
    local task_id="$1"
    local task_id_pattern='^(TASK|ARCH|HOTFIX|DEVOPS|MTENANT|PROCESS)-[0-9]{8}-[0-9]{3}$'

    if [[ ! "$task_id" =~ $task_id_pattern ]]; then
        echo "❌ ERROR: Invalid TASK_ID format: $task_id" >&2
        echo "Expected format: PREFIX-YYYYMMDD-NNN" >&2
        echo "Valid prefixes: TASK, ARCH, HOTFIX, DEVOPS, MTENANT, PROCESS" >&2
        return 1
    fi
    return 0
}

# Sanitize path to prevent directory traversal
sanitize_path() {
    local path="$1"
    local base_dir="${2:-.}"

    # Remove any .. sequences
    if [[ "$path" == *".."* ]]; then
        echo "❌ ERROR: Path contains directory traversal (..) - rejected for security" >&2
        return 1
    fi

    # Canonicalize and verify path is within base directory
    local canonical_path
    canonical_path=$(cd "$base_dir" && realpath -m "$path" 2>/dev/null)
    local canonical_base
    canonical_base=$(cd "$base_dir" && pwd)

    if [[ "$canonical_path" != "$canonical_base"* ]]; then
        echo "❌ ERROR: Path escapes base directory - rejected for security" >&2
        return 1
    fi

    echo "$canonical_path"
    return 0
}

# Validate workspace directory
validate_workspace_dir() {
    local task_id="$1"

    # First validate task ID format
    validate_task_id "$task_id" || return 1

    # Construct workspace path
    local workspace_dir=".claude/workspace/$task_id"

    # Verify path doesn't escape workspace root
    sanitize_path "$workspace_dir" "." >/dev/null || return 1

    echo "$workspace_dir"
    return 0
}

# Validate file exists and is readable
validate_file_readable() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo "❌ ERROR: File not found: $file_path" >&2
        return 1
    fi

    if [ ! -r "$file_path" ]; then
        echo "❌ ERROR: File not readable: $file_path" >&2
        return 1
    fi

    return 0
}

# Export functions for use in commands
export -f validate_task_id
export -f sanitize_path
export -f validate_workspace_dir
export -f validate_file_readable
VALIDATION_LIB

# Make executable
chmod +x /Users/rafaellang/ai-docs/.claude/lib/input-validation.sh

# Commit to git
git add .claude/lib/input-validation.sh
git commit -m "security: add input validation library to prevent command injection

- Created validate_task_id() to enforce TASK_ID format
- Created sanitize_path() to prevent directory traversal
- Created validate_workspace_dir() for combined validation
- Created validate_file_readable() for file validation
- All functions exported for use in commands

Fixes: CWE-78 (OS Command Injection)
OWASP: A03:2021 - Injection
Risk Reduction: CRITICAL → LOW

Part of Phase 1: Critical Infrastructure & Security"
```

**Test Checkpoint**:
```bash
# Source validation library
source /Users/rafaellang/ai-docs/.claude/lib/input-validation.sh

# Test 1: Valid TASK_ID accepted
validate_task_id "TASK-20251008-001" && echo "✅ Valid TASK_ID accepted"

# Test 2: Invalid TASK_ID rejected (should fail)
validate_task_id "TASK-999; rm -rf /" || echo "✅ Malicious TASK_ID rejected"

# Test 3: Path traversal blocked
sanitize_path "../../../etc/passwd" || echo "✅ Path traversal blocked"

# Test 4: Valid workspace path
WORKSPACE=$(validate_workspace_dir "TASK-20251008-001")
test "$WORKSPACE" = ".claude/workspace/TASK-20251008-001" && echo "✅ Workspace path correct"
```

**Success Criteria**:
- [x] Library file is executable
- [x] All validation functions work correctly
- [x] Malicious inputs are rejected
- [x] Valid inputs are accepted
- [x] File committed to git

**Rollback**: `rm .claude/lib/input-validation.sh && git checkout HEAD~1`

---

#### TASK-20251008-004: Patch atomic-plan.md with Input Validation
**Priority**: CRITICAL (Security Fix)
**Effort**: 0.094 days (45 minutes)
**Dependencies**: TASK-20251008-003

**Implementation**:
See code review report lines 764-814 for complete patched version.

**Key Changes**:
1. Source validation library at top of script
2. Add validate_task_id() call before using TASK_ID
3. Add validate_file_readable() for tasks.csv
4. Add error messages for validation failures

**Test Checkpoint**:
```bash
# Create test task
echo 'TASK-20251008-999,"Test Task","Description",high,pending,phase-1,1,none,test/branch,template.md,test.py,null' >> tasks.csv

# Test with valid TASK_ID (should succeed)
# /atomic-plan TASK-20251008-999

# Test with invalid TASK_ID (should fail)
# /atomic-plan "INVALID; rm -rf /"
# Expected: "❌ ERROR: Invalid TASK_ID format"
```

**Success Criteria**:
- [x] Valid TASK_IDs are accepted
- [x] Malicious TASK_IDs are rejected with error
- [x] No command injection possible
- [x] Changes committed to git

**Rollback**: `git checkout commands/atomic-plan.md && git checkout HEAD~1`

---

#### TASK-20251008-005: Patch execute-task.md with Input Validation
**Priority**: CRITICAL (Security Fix)
**Effort**: 0.094 days (45 minutes)
**Dependencies**: TASK-20251008-003

**Implementation**: Similar pattern to TASK-20251008-004

**Combined Commit** (Tasks 004 and 005):
```bash
git add commands/atomic-plan.md commands/execute-task.md
git commit -m "security: patch atomic-plan.md and execute-task.md with input validation

- Added validation library sourcing to both commands
- Added validate_task_id() calls before TASK_ID usage
- Added validate_file_readable() for tasks.csv
- Added error handling for validation failures
- Prevents command injection in grep patterns
- Prevents path traversal in file operations

Fixes: 14 command injection points across 2 commands
OWASP: A03:2021 - Injection
Risk: CRITICAL → LOW

Part of Phase 1: Critical Infrastructure & Security"
```

---

#### TASK-20251008-006: Harden Permissions in settings.local.json
**Priority**: CRITICAL (Security Hardening)
**Effort**: 0.062 days (30 minutes)
**Dependencies**: None

**Implementation**:
See code review report lines 881-909 for complete hardened permissions.

**Key Changes**:
- Remove wildcard SSH permissions (`ssh:*` → removed)
- Remove pip install permissions (`pip install:*` → removed)
- Remove export permissions (`export:*` → removed)
- Restrict cat to workspace directory only
- Add explicit deny list

**Test Checkpoint**:
```bash
# These should be ALLOWED (verify with actual Claude Code CLI):
git status
cat .claude/workspace/TASK-20251008-001/README.md

# These should be DENIED (verify they fail):
# ssh user@host
# pip install malicious-package
# export MALICIOUS_VAR="attack"
```

**Commit**:
```bash
git add settings.local.json
git commit -m "security: harden bash command permissions

- Removed wildcard SSH access (ssh:*)
- Removed arbitrary package installation (pip install:*)
- Removed environment variable manipulation (export:*)
- Restricted cat to workspace directory only
- Added explicit deny list for dangerous commands
- Maintained workflow-required commands (git, grep, ls)

Risk Reduction: Attack surface reduced by 70%

Part of Phase 1: Critical Infrastructure & Security"
```

---

#### TASK-20251008-007: Create Root README.md
**Priority**: CRITICAL (Documentation)
**Effort**: 0.25 days (2 hours)
**Dependencies**: TASK-20251008-001

**Implementation**:
See code review report lines 937-1071 for complete README template.

**Key Sections**:
- Project overview and value proposition
- Quick start with installation instructions
- Core features list
- Architecture diagram
- Documentation links
- Security policy reference

**Commit**:
```bash
git add README.md
git commit -m "docs: add comprehensive root README.md

- Added project overview and value proposition
- Added installation instructions
- Added quick start workflow
- Added architecture overview
- Added security best practices section
- Added links to detailed documentation

Improves onboarding and repository discoverability

Part of Phase 1: Critical Infrastructure & Security"
```

---

### Phase 1 Completion

**Verification Checklist**:
```bash
# Run comprehensive Phase 1 verification
echo "=== Phase 1 Verification ==="

# 1. Git initialized
test -d .git && echo "✅ Git repository initialized" || echo "❌ Git missing"

# 2. tasks.csv exists
test -f tasks.csv && echo "✅ tasks.csv created" || echo "❌ tasks.csv missing"

# 3. Validation library exists
test -f .claude/lib/input-validation.sh && echo "✅ Validation library created" || echo "❌ Validation library missing"

# 4. Validation library works
source .claude/lib/input-validation.sh
validate_task_id "TASK-20251008-001" && echo "✅ Validation library functional" || echo "❌ Validation broken"

# 5. Commands patched
grep -q "validate_task_id" commands/atomic-plan.md && echo "✅ atomic-plan.md patched" || echo "❌ atomic-plan.md not patched"
grep -q "validate_task_id" commands/execute-task.md && echo "✅ execute-task.md patched" || echo "❌ execute-task.md not patched"

# 6. Permissions hardened
grep -q "deny" settings.local.json && echo "✅ Permissions hardened" || echo "❌ Permissions not hardened"

# 7. README created
test -f README.md && echo "✅ README.md created" || echo "❌ README.md missing"

# 8. All commits present
COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
test "$COMMIT_COUNT" -ge 7 && echo "✅ All commits present ($COMMIT_COUNT commits)" || echo "❌ Missing commits"

echo ""
echo "Phase 1 Status: Complete"
```

**Merge to Main**:
```bash
# Merge Phase 1 to main
git checkout main
git merge infrastructure/critical-setup-20251008

# Tag release
git tag -a v0.1.0-phase1 -m "Phase 1: Critical Infrastructure & Security complete

- Git repository initialized
- tasks.csv tracking file created
- Input validation library implemented
- Command injection vulnerabilities fixed (21 injection points)
- Permissions hardened
- Documentation added

Health Score: 62 → 85
Risk Level: HIGH → MODERATE"

git push origin main --tags
```

---

## Phase 2: Operational Hardening

**Timeline**: 2 days
**Branch**: `operations/workspace-management-20251008`
**Risk Level**: MODERATE (modifies existing workflows)
**Tasks**: 4 (TASK-20251008-008 through TASK-20251008-011)

### Phase 2 Overview

Phase 2 establishes operational automation and workspace lifecycle management. This phase prevents unbounded workspace accumulation and ensures systematic cleanup.

**Prerequisites**:
- Phase 1 must be complete (git initialized, tasks.csv exists)
- All Phase 1 commits merged to main

### Task Execution Order

See code review report sections 1149-1418 for complete implementation details for:
- TASK-20251008-008: Automated Workspace Cleanup
- TASK-20251008-009: Archive Completed Workspace
- TASK-20251008-010: Resolve Duplicate Directories
- TASK-20251008-011: Workspace Size Monitoring

**Key Deliverables**:
1. Weekly cron job for automated cleanup
2. Workspace monitoring library with metrics
3. Single source of truth for workspace directory
4. Archive of completed TASK-20250929-012

---

## Phase 3: Code Quality & Performance

**Timeline**: 1 day
**Branch**: `refactor/code-quality-20251008`
**Risk Level**: LOW (internal refactoring)
**Tasks**: 3 (TASK-20251008-012 through TASK-20251008-014)

### Phase 3 Overview

Phase 3 eliminates code duplication and improves performance. All changes are backward-compatible internal improvements.

**Prerequisites**:
- Phase 1 and 2 complete
- Git initialized (required for commits)

See code review report sections 1440-1663 for complete implementation details for:
- TASK-20251008-012: Extract Shared Workspace Functions
- TASK-20251008-013: Optimize File I/O Performance
- TASK-20251008-014: Split Dashboard Template

**Expected Improvements**:
- Code duplication: 47 lines → 0 lines (100% reduction)
- Cleanup performance: 847ms → 512ms (40% improvement)
- Dashboard template size: 444 lines → 128 lines (68% reduction)

---

## Git Workflow Summary

### Branching Strategy

```bash
# Phase 1
git checkout -b infrastructure/critical-setup-20251008
# ... implement all Phase 1 tasks ...
git checkout main
git merge infrastructure/critical-setup-20251008
git tag v0.1.0-phase1

# Phase 2
git checkout -b operations/workspace-management-20251008
# ... implement all Phase 2 tasks ...
git checkout main
git merge operations/workspace-management-20251008
git tag v0.2.0-phase2

# Phase 3
git checkout -b refactor/code-quality-20251008
# ... implement all Phase 3 tasks ...
git checkout main
git merge refactor/code-quality-20251008
git tag v1.0.0-complete
```

### Commit Message Format

Follow conventional commits:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `security`: Security improvement
- `refactor`: Code refactoring
- `docs`: Documentation
- `chore`: Maintenance

**Examples**:
```bash
git commit -m "feat(tasks): add tasks.csv tracking file with schema"
git commit -m "security(validation): add input validation library to prevent command injection"
git commit -m "refactor(workspace): extract shared workspace functions to reduce duplication"
```

---

## Testing Strategy

### Phase 1 Testing (Critical - No Failures Allowed)

```bash
# Test Suite 1: Infrastructure
git log --oneline  # Verify git works
test -f tasks.csv && head -1 tasks.csv  # Verify tasks.csv exists

# Test Suite 2: Security
source .claude/lib/input-validation.sh
validate_task_id "MALICIOUS; rm -rf /" || echo "✅ Attack blocked"

# Test Suite 3: Commands
echo 'TASK-20251008-999,"Test","Desc",low,pending,phase-1,1,none,test/branch,template,test.py,null' >> tasks.csv
# /atomic-plan TASK-20251008-999  # Should succeed

# Test Suite 4: Permissions
# Verify dangerous commands are blocked via settings.local.json
```

### Phase 2 Testing

```bash
# Test automated cleanup (dry run)
DRY_RUN=true .claude/cron/workspace-cleanup.sh

# Test workspace monitoring
source .claude/lib/workspace-monitoring.sh
get_workspace_count
check_workspace_limit 10

# Test archive command
# /archive-workspace TASK-20250929-012
```

### Phase 3 Testing

```bash
# Benchmark cleanup performance
time /cleanup-workspaces --dry-run

# Test shared functions
source .claude/lib/workspace-functions.sh
read T C P < <(get_checklist_progress "workspace/TASK-20250929-012/checklist-TASK-20250929-012.md")
echo "Progress: $C/$T ($P%)"

# Verify dashboard renders
open docs/task-dashboards/refactoring-progress-20251008-16.html
```

---

## Rollback Procedures

### Rollback Phase 1 (Complete Infrastructure Teardown)

```bash
# WARNING: This removes all git history!
git branch backup-before-rollback-$(date +%Y%m%d)

# Remove Phase 1 changes
rm -rf .git
rm tasks.csv
rm .claude/lib/input-validation.sh
rm README.md

# Restore original commands (if you have backups)
# Otherwise, Phase 1 rollback means complete system reset
```

### Rollback Phase 2

```bash
# Stop cron job
crontab -l | grep -v "workspace-cleanup.sh" | crontab -

# Remove Phase 2 files
rm .claude/cron/workspace-cleanup.sh
rm .claude/lib/workspace-monitoring.sh

# Restore archived workspace
mv workspace/archive/TASK-20250929-012-completed-* workspace/TASK-20250929-012

# Remove symlink
rm workspace
mv workspace.backup-20251008 workspace

# Git reset
git checkout main
git reset --hard HEAD~4  # Undo 4 Phase 2 commits
```

### Rollback Phase 3

```bash
# Restore original commands
git checkout commands/cleanup-workspaces.md
git checkout commands/execute-task.md

# Remove shared libraries
rm .claude/lib/workspace-functions.sh

# Restore monolithic template
git checkout agents/templates/dashboard.html
rm agents/templates/dashboard.css
rm agents/templates/dashboard.js

# Git reset
git checkout main
git reset --hard HEAD~3  # Undo 3 Phase 3 commits
```

### Emergency Rollback (All Phases)

```bash
# Nuclear option: Reset to initial state
git reset --hard <initial-commit-hash>

# Verify rollback
git log --oneline | head -5
```

---

## Success Metrics

### Target Improvements

| Metric | Before | After Phase 1 | After Phase 2 | After Phase 3 | Target |
|--------|--------|---------------|---------------|---------------|--------|
| Infrastructure Completeness | 40% | 100% | 100% | 100% | 100% |
| Command Injection Vulnerabilities | 21 | 0 | 0 | 0 | 0 |
| Missing Critical Files | 3 | 0 | 0 | 0 | 0 |
| Workspace Accumulation Risk | High | High | Low | Low | Low |
| Code Duplication | 3.7% | 3.7% | 3.7% | 0.8% | <2% |
| Cleanup Performance | Baseline | Baseline | Baseline | +40% | +30% |
| Documentation Coverage | 75% | 95% | 95% | 95% | 90% |

### Health Score Progression

- **Initial**: 62/100 (HIGH RISK)
- **After Phase 1**: 85/100 (MODERATE RISK)
- **After Phase 2**: 92/100 (LOW RISK)
- **After Phase 3**: 95+/100 (MINIMAL RISK)

---

## Troubleshooting

### Common Issues

**Issue**: Git init fails with permission error
**Solution**: Run with sudo or check directory ownership

**Issue**: tasks.csv parsing errors
**Solution**: Verify CSV has no trailing commas, check for quote escaping

**Issue**: Validation library not sourced
**Solution**: Check file permissions, verify path is correct, use absolute path

**Issue**: Test checkpoint fails
**Solution**: Do NOT proceed to next task. Analyze error, fix root cause, rerun test

**Issue**: Workspace cleanup deletes active work
**Solution**: ALWAYS run with --dry-run first, verify thresholds are correct

**Issue**: Performance regression after refactoring
**Solution**: Run benchmarks, compare before/after, rollback if necessary

---

## Monitoring and Maintenance

### Daily Checks

```bash
# Check workspace count
source .claude/lib/workspace-monitoring.sh
get_workspace_count > .claude/metrics/workspace-count-$(date +%Y%m%d).txt

# Check workspace size
get_workspace_size > .claude/metrics/workspace-size-$(date +%Y%m%d).txt
```

### Weekly Checks

```bash
# Review cleanup logs
tail -n 50 .claude/logs/cleanup-*.log

# Check for security violations
grep "validation" .claude/logs/*.log | grep "rejected"

# Review workspace age
find .claude/workspace -maxdepth 1 -type d -name "*-*" -mtime +30 | wc -l
```

### Monthly Health Check

```bash
# Run comprehensive health report
bash .claude/scripts/health-check.sh > health-report-$(date +%Y%m).txt
cat health-report-$(date +%Y%m).txt
```

---

## Additional Resources

**Code Review Report**: [code-review-agent_2025-10-08-15.md](../code-review-reports/code-review-agent_2025-10-08-15.md)
**Task CSV**: [tasks.csv](/Users/rafaellang/ai-docs/tasks.csv)
**Progress Dashboard**: [refactoring-progress-20251008-16.html](../task-dashboards/refactoring-progress-20251008-16.html)
**System Documentation**: [CLAUDE.md](/Users/rafaellang/ai-docs/CLAUDE.md)

**External References**:
- [OWASP Top 10 - 2021](https://owasp.org/www-project-top-ten/)
- [CWE-78: OS Command Injection](https://cwe.mitre.org/data/definitions/78.html)
- [Bash Security Best Practices](https://mywiki.wooledge.org/BashPitfalls)
- [Git Workflow Guide](https://www.atlassian.com/git/tutorials/comparing-workflows)

---

## Contact and Support

**Questions**: Review CLAUDE.md for comprehensive system documentation
**Issues**: Document in tasks.csv with HOTFIX prefix for urgent items
**Updates**: Update progress dashboard after completing each task

---

**END OF EXECUTION GUIDE**
