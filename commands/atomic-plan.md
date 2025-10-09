---
description: Generate an atomic execution plan for a specific task from tasks.csv, breaking it into concrete work session steps
allowed-tools: Read, Write, Bash, Glob, Grep, general-purpose
argument-hint: [task-id] - Task ID from tasks.csv (e.g., TASK-20250929-001, HOTFIX-20251001-001)
---

# Atomic Plan

Create a detailed, step-by-step execution plan for completing a specific task in a single work session, with atomic commits, test checkpoints, and rollback strategies.

## Pre-Planning Discovery

### Locate and Read Task Details
```bash
# SECURITY NOTE: Command Injection Prevention (CWE-78)
# All user-supplied input (TASK_ID) is validated before use in commands
# to prevent OS command injection attacks. This follows OWASP A03:2021
# (Injection) mitigation guidelines.
#
# Attack vectors blocked:
# - Semicolon injection: TASK-001; rm -rf /
# - Backtick injection: TASK-`whoami`-001
# - Command substitution: TASK-$(whoami)-001
# - Path traversal: ../../../etc/passwd
#
# Defense strategy:
# 1. Validate TASK_ID format with strict regex
# 2. Validate file existence before reading
# 3. Validate workspace paths to prevent directory escapes
#
# Source validation library for input sanitization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/.claude/lib"

if [ -f "$LIB_DIR/input-validation.sh" ]; then
    source "$LIB_DIR/input-validation.sh"
else
    echo "❌ ERROR: Input validation library not found"
    echo "Expected: $LIB_DIR/input-validation.sh"
    echo "Run: TASK-20251008-003 to create validation library"
    exit 1
fi

# Get TASK_ID from argument
TASK_ID="${1}"

# If no TASK_ID provided, find first pending task
if [ -z "$TASK_ID" ]; then
    # Validate tasks.csv exists before reading
    if ! validate_file_readable "tasks.csv"; then
        echo "❌ ERROR: tasks.csv not found or not readable"
        echo "Run: /generate_tasks to create tasks.csv"
        exit 1
    fi

    # Find first pending task
    TASK_ID=$(grep ",pending," tasks.csv 2>/dev/null | head -1 | cut -d',' -f1)

    if [ -z "$TASK_ID" ]; then
        echo "❌ ERROR: No pending tasks found in tasks.csv"
        echo "Usage: /atomic-plan TASK-ID"
        echo ""
        echo "Available tasks:"
        grep -v "^task_id," tasks.csv | cut -d',' -f1,2,5 | head -5
        exit 1
    fi
fi

# SECURITY: Validate TASK_ID format before using in any commands
echo "🔒 Validating TASK_ID: $TASK_ID"
if ! validate_task_id "$TASK_ID"; then
    echo ""
    echo "Security: TASK_ID validation failed"
    echo "This prevents command injection attacks"
    exit 1
fi

echo "📋 Planning execution for: $TASK_ID"
echo ""

# Validate tasks.csv is readable
if ! validate_file_readable "tasks.csv"; then
    echo "❌ ERROR: tasks.csv not found or not readable"
    exit 1
fi

# Extract task details (now safe - TASK_ID is validated above)
TASK_ROW=$(grep "^$TASK_ID," tasks.csv 2>/dev/null)
if [ -z "$TASK_ROW" ]; then
    echo "❌ Task $TASK_ID not found in tasks.csv"
    echo ""
    echo "Available tasks:"
    grep -v "^task_id," tasks.csv | cut -d',' -f1,2 | head -10
    exit 1
fi

# Parse task fields
TASK_TITLE=$(echo "$TASK_ROW" | cut -d',' -f2)
TASK_DESC=$(echo "$TASK_ROW" | cut -d',' -f3)
TASK_PRIORITY=$(echo "$TASK_ROW" | cut -d',' -f4)
TASK_STATUS=$(echo "$TASK_ROW" | cut -d',' -f5)
TASK_PHASE=$(echo "$TASK_ROW" | cut -d',' -f6)
TASK_EFFORT=$(echo "$TASK_ROW" | cut -d',' -f7)
TASK_DEPS=$(echo "$TASK_ROW" | cut -d',' -f8)
TASK_BRANCH=$(echo "$TASK_ROW" | cut -d',' -f9)

echo "📝 Task Information:"
echo "  Title: $TASK_TITLE"
echo "  Priority: $TASK_PRIORITY"
echo "  Status: $TASK_STATUS"
echo "  Phase: $TASK_PHASE"
echo "  Effort: $TASK_EFFORT days"
echo "  Dependencies: $TASK_DEPS"
echo "  Branch: $TASK_BRANCH"
echo ""
```

### Verify Dependencies
```bash
# Check if dependencies are completed
if [ "$TASK_DEPS" != "none" ] && [ -n "$TASK_DEPS" ]; then
    echo "🔍 Checking dependencies..."

    IFS=',' read -ra DEPS <<< "$TASK_DEPS"
    ALL_DEPS_MET=true

    for DEP in "${DEPS[@]}"; do
        DEP=$(echo "$DEP" | xargs)  # Trim whitespace
        DEP_STATUS=$(grep "^$DEP," tasks.csv | cut -d',' -f5)

        if [ "$DEP_STATUS" != "completed" ]; then
            echo "  ❌ $DEP: $DEP_STATUS (not completed)"
            ALL_DEPS_MET=false
        else
            echo "  ✅ $DEP: completed"
        fi
    done

    if [ "$ALL_DEPS_MET" = false ]; then
        echo ""
        echo "⚠️  WARNING: Not all dependencies are completed!"
        echo "Proceed with caution or complete dependencies first."
        echo ""
    fi
else
    echo "✅ No dependencies - task ready to start"
    echo ""
fi
```

### Analyze Current Codebase State
```bash
# Check git status
echo "🔍 Analyzing repository state..."

if git rev-parse --git-dir > /dev/null 2>&1; then
    CURRENT_BRANCH=$(git branch --show-current)
    echo "  Current branch: $CURRENT_BRANCH"

    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "  ⚠️  Uncommitted changes detected:"
        git status --short
        echo ""
        echo "  Consider stashing or committing before proceeding"
    else
        echo "  ✅ Working directory clean"
    fi

    # Check if task branch exists
    if git show-ref --verify --quiet "refs/heads/$TASK_BRANCH"; then
        echo "  📌 Task branch exists: $TASK_BRANCH"
    else
        echo "  🌿 Task branch will be created: $TASK_BRANCH"
    fi
else
    echo "  ⚠️  Not a git repository"
fi
echo ""
```

### Identify Affected Files
```bash
# Search for files related to task based on common patterns
echo "🔍 Identifying affected files..."

# Extract key terms from task title and description
SEARCH_TERMS=$(echo "$TASK_TITLE $TASK_DESC" | tr '[:upper:]' '[:lower:]' | grep -oE '\b[a-z]{4,}\b' | sort -u)

# Common file patterns based on task phase
case "$TASK_PHASE" in
    "1"|"phase-1")
        echo "  Phase 1: Route/Controller extraction"
        find app/ -name "*.py" -type f 2>/dev/null | head -10
        ;;
    "2"|"phase-2")
        echo "  Phase 2: Performance optimization"
        find app/services/ -name "*.py" -type f 2>/dev/null
        ;;
    "3"|"phase-3")
        echo "  Phase 3: Architecture improvements"
        find app/ -name "*.py" -type f 2>/dev/null | head -10
        ;;
    "0"|"phase-0")
        echo "  Phase 0: Hotfix/Emergency"
        # Focus on recently modified files
        git log --name-only --pretty=format: --since="1 week ago" | sort -u | head -10
        ;;
esac
echo ""
```

## Atomic Plan Generation

### Invoke General-Purpose Agent for Plan Creation
```
@general-purpose

Please create a detailed atomic execution plan for the following task:

**Task ID**: $TASK_ID
**Title**: $TASK_TITLE
**Description**: $TASK_DESC
**Priority**: $TASK_PRIORITY
**Estimated Effort**: $TASK_EFFORT days
**Phase**: $TASK_PHASE
**Branch**: $TASK_BRANCH

**Current Context**:
- Current Branch: $(git branch --show-current)
- Repository Status: $(git status --short | wc -l) uncommitted changes
- Dependencies Status: [Analyzed above]

**Plan Requirements**:

Generate a comprehensive execution plan with the following structure:

## 1. PREPARATION PHASE (Pre-work)
- [ ] Environment setup (dependencies, configs)
- [ ] Branch creation/checkout
- [ ] Baseline tests execution
- [ ] Documentation review
- [ ] Success criteria definition

## 2. IMPLEMENTATION PHASE (Atomic Steps)

Break down the task into 5-10 atomic steps, each with:
- **Step Number**: Sequential step identifier
- **Action**: Concrete action to take (read file, create class, modify function, etc.)
- **Files**: Specific files to create/modify
- **Test Checkpoint**: How to verify this step worked
- **Commit Message**: Atomic commit message for this step
- **Rollback**: How to undo if this step fails
- **Estimated Time**: Time estimate for this step (in minutes)

Example atomic step format:
```
### Step 3: Extract Quote Processing Logic
**Action**: Move data processing from main.py to QuoteListPresenter.present()
**Files**:
  - Create: app/presenters/quote_presenter.py
  - Modify: main.py (lines 932-989)
**Code**:
  - Extract 85 lines of quote data processing
  - Create QuoteListPresenter class with present() method
**Test Checkpoint**:
  ```bash
  python -c "from app.presenters.quote_presenter import QuoteListPresenter; print('✓ Import successful')"
  ```
**Commit Message**:
  ```
  refactor: extract quote data processing to QuoteListPresenter

  - Created app/presenters/quote_presenter.py
  - Moved 85 lines from main.py to presenter pattern
  - Maintains template compatibility

  Task: $TASK_ID
  ```
**Rollback**: `git checkout main.py app/presenters/`
**Time**: 20 minutes
```

## 3. INTEGRATION PHASE
- [ ] Update route handlers to use new code
- [ ] Update imports and dependencies
- [ ] Integration test execution
- [ ] Manual smoke testing steps

## 4. TESTING PHASE
- [ ] Unit test creation/update
- [ ] Integration test verification
- [ ] End-to-end test scenarios
- [ ] Performance benchmarks (if applicable)

## 5. DEPLOYMENT PHASE
- [ ] Test environment deployment
- [ ] Test environment verification
- [ ] Production deployment steps
- [ ] Production smoke test checklist
- [ ] Rollback procedure if needed

## 6. DOCUMENTATION PHASE
- [ ] Code comments update
- [ ] API documentation update
- [ ] Update TASK_STATUS.md
- [ ] Update progress dashboard

**Output Format**:
Create a markdown file named `atomic-plan-$TASK_ID.md` with:
1. Executive summary (1-2 sentences)
2. Success criteria (3-5 measurable outcomes)
3. Detailed phase-by-phase plan
4. Risk assessment and mitigation
5. Time estimates for each phase
6. Rollback strategy
7. Testing checklist

**Special Considerations**:
- Each step should be independently testable
- Each commit should be atomic and revertible
- Include specific file paths and line numbers where applicable
- Provide exact bash commands to run
- Include expected output for verification
- Consider edge cases and error handling
```

## Post-Plan Actions

### Validate Generated Plan
```bash
PLAN_FILE="atomic-plan-$TASK_ID.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "❌ Plan file not generated: $PLAN_FILE"
    exit 1
fi

echo "✅ Atomic plan generated: $PLAN_FILE"
echo ""

# Check plan completeness
echo "🔍 Validating plan structure..."

REQUIRED_SECTIONS=(
    "PREPARATION PHASE"
    "IMPLEMENTATION PHASE"
    "INTEGRATION PHASE"
    "TESTING PHASE"
    "DEPLOYMENT PHASE"
    "DOCUMENTATION PHASE"
)

for SECTION in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$SECTION" "$PLAN_FILE"; then
        echo "  ✅ $SECTION found"
    else
        echo "  ⚠️  $SECTION missing"
    fi
done
echo ""

# Count atomic steps
STEP_COUNT=$(grep -c "^### Step [0-9]" "$PLAN_FILE" || echo 0)
echo "📊 Plan contains $STEP_COUNT atomic implementation steps"

if [ "$STEP_COUNT" -lt 3 ]; then
    echo "  ⚠️  Warning: Less than 3 steps. Consider more granular breakdown."
elif [ "$STEP_COUNT" -gt 15 ]; then
    echo "  ⚠️  Warning: More than 15 steps. Consider combining some steps."
else
    echo "  ✅ Good step granularity"
fi
echo ""
```

### Create Execution Checklist
```bash
# Extract all checkboxes from plan
echo "📝 Creating execution checklist..."

grep -E '^\- \[ \]' "$PLAN_FILE" > "checklist-$TASK_ID.md"

TOTAL_ITEMS=$(wc -l < "checklist-$TASK_ID.md")
echo "✅ Checklist created: $TOTAL_ITEMS items to complete"
echo "   File: checklist-$TASK_ID.md"
echo ""
```

### Setup Workspace
```bash
# SECURITY: Validate workspace directory path to prevent path traversal
# This prevents attacks like: /atomic-plan "../../../etc"
echo "🔒 Validating workspace directory..."
WORKSPACE_DIR=$(validate_workspace_dir "$TASK_ID")

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Workspace directory validation failed"
    echo "This prevents path traversal attacks"
    exit 1
fi

# Create task-specific workspace directory (now safe - path validated)
mkdir -p "$WORKSPACE_DIR"

echo "📁 Task workspace created: $WORKSPACE_DIR"
echo ""

# Copy relevant files to workspace
echo "📋 Workspace structure:"
cat > "$WORKSPACE_DIR/README.md" << EOF
# Task Workspace: $TASK_ID

**Title**: $TASK_TITLE
**Started**: $(date +"%Y-%m-%d %H:%M:%S")

## Files
- \`atomic-plan-$TASK_ID.md\` - Detailed execution plan
- \`checklist-$TASK_ID.md\` - Execution checklist
- \`notes.md\` - Session notes and observations
- \`errors.log\` - Error log if issues occur

## Quick Commands

### Start work session
\`\`\`bash
git checkout -b $TASK_BRANCH
cat atomic-plan-$TASK_ID.md
\`\`\`

### Track progress
\`\`\`bash
grep "\\[x\\]" checklist-$TASK_ID.md | wc -l  # Completed items
grep "\\[ \\]" checklist-$TASK_ID.md | wc -l  # Remaining items
\`\`\`

### After completion
\`\`\`bash
# Update task status
sed -i '' "s/$TASK_ID,\\([^,]*\\),[^,]*,/$TASK_ID,\\1,completed,/" tasks.csv

# Update task tracker
echo "Completed: $(date)" >> notes.md
\`\`\`
EOF

# Move generated files to workspace
mv "atomic-plan-$TASK_ID.md" "$WORKSPACE_DIR/" 2>/dev/null
mv "checklist-$TASK_ID.md" "$WORKSPACE_DIR/" 2>/dev/null

# Create notes file
touch "$WORKSPACE_DIR/notes.md"

echo "  - $WORKSPACE_DIR/README.md"
echo "  - $WORKSPACE_DIR/atomic-plan-$TASK_ID.md"
echo "  - $WORKSPACE_DIR/checklist-$TASK_ID.md"
echo "  - $WORKSPACE_DIR/notes.md"
echo ""
```

### Display Execution Summary
```bash
# Print execution summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                   ATOMIC PLAN READY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Task: $TASK_ID"
echo "📝 Title: $TASK_TITLE"
echo "⏱️  Estimated Effort: $TASK_EFFORT days"
echo "📂 Workspace: $WORKSPACE_DIR"
echo ""
echo "🚀 Next Steps:"
echo "   1. Review plan: cat $WORKSPACE_DIR/atomic-plan-$TASK_ID.md"
echo "   2. Start work: git checkout -b $TASK_BRANCH"
echo "   3. Follow plan: Follow atomic steps from the plan"
echo "   4. Track progress: Update $WORKSPACE_DIR/checklist-$TASK_ID.md"
echo "   5. Complete: Mark task as completed in tasks.csv"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Expected Outcomes

After executing this command, you should have:

### **Immediate Outputs**
1. **Atomic Plan Document**: `atomic-plan-{TASK_ID}.md` with detailed step-by-step plan
2. **Execution Checklist**: `checklist-{TASK_ID}.md` with all action items
3. **Task Workspace**: `.claude/workspace/{TASK_ID}/` directory with all materials
4. **Workspace README**: Quick reference for the task execution

### **Workspace Structure**
```
.claude/workspace/{TASK_ID}/
├── README.md                      # Workspace quick reference
├── atomic-plan-{TASK_ID}.md       # Detailed execution plan
├── checklist-{TASK_ID}.md         # Execution checklist
├── notes.md                       # Session notes
└── errors.log                     # Error tracking (if needed)
```

### **Atomic Plan Contents**
Each plan includes:
- **Executive Summary**: What this task accomplishes
- **Success Criteria**: Measurable outcomes to verify completion
- **6 Execution Phases**: Preparation → Implementation → Integration → Testing → Deployment → Documentation
- **Atomic Steps**: 5-15 granular steps with:
  - Specific actions
  - Files to modify
  - Test checkpoints
  - Commit messages
  - Rollback procedures
  - Time estimates
- **Risk Assessment**: Potential issues and mitigation strategies
- **Total Time Estimate**: Realistic time expectation
- **Rollback Strategy**: Complete undo procedure

### **Developer Workflow Enabled**
1. **Clear Path Forward**: No ambiguity about what to do next
2. **Testable Progress**: Each step has verification criteria
3. **Safe Iteration**: Atomic commits allow easy rollback
4. **Time Management**: Realistic estimates for planning
5. **Documentation Trail**: Notes and logs for retrospective

### **Quality Assurance**
- Each step independently verifiable
- Test checkpoints prevent integration issues
- Rollback procedures reduce risk
- Documentation updates ensure knowledge transfer

## Troubleshooting

### Task Not Found
```bash
# Solution: List available tasks
echo "Available tasks:"
cat tasks.csv | column -t -s','

# Or search by keyword
grep -i "keyword" tasks.csv
```

### Dependencies Not Met
```bash
# Solution: Check dependency status
TASK_DEPS=$(grep "^$TASK_ID," tasks.csv | cut -d',' -f8)
for DEP in $(echo "$TASK_DEPS" | tr ',' ' '); do
    grep "^$DEP," tasks.csv
done

# Complete dependencies first, or override if acceptable
```

### Plan Too Vague
```bash
# Solution: Request more detailed plan
# Add more context to the task description
# Or break task into smaller sub-tasks in tasks.csv
```

### Workspace Already Exists
```bash
# Solution: Archive old workspace
ARCHIVE_DIR=".claude/workspace/archive"
mkdir -p "$ARCHIVE_DIR"
mv ".claude/workspace/$TASK_ID" "$ARCHIVE_DIR/${TASK_ID}-$(date +%Y%m%d-%H%M%S)"

# Then regenerate plan
/atomic-plan $TASK_ID
```

### Git Branch Conflicts
```bash
# Solution: Resolve conflicts before planning
git status
git stash  # If needed
git checkout main
git pull origin main

# Then regenerate plan
/atomic-plan $TASK_ID
```

### Estimation Concerns
```bash
# If plan estimates seem off, consider:
# 1. Breaking task into smaller tasks
# 2. Adding buffer time for unknowns
# 3. Consulting with team members
# 4. Reviewing similar completed tasks for reference
```

## Advanced Usage

### Create Plan for Specific Phase
```bash
# Example: Plan only for implementation phase
/atomic-plan TASK-ID --phase implementation
```

### Generate Time-boxed Plan
```bash
# Example: Create 2-hour work session plan
/atomic-plan TASK-ID --timebox 2h
```

### Include Specific Context
```bash
# Example: Add specific files to analyze
/atomic-plan TASK-ID --context "main.py app/routes/quotes.py"
```

### Parallel Task Planning
```bash
# Plan multiple independent tasks
/atomic-plan TASK-001 TASK-004 TASK-007
```

## Best Practices

1. **Review Plan Before Starting**: Read entire plan, understand all steps
2. **One Step at a Time**: Complete each atomic step fully before moving on
3. **Test After Each Step**: Run test checkpoint, verify success
4. **Commit After Each Step**: Create atomic commit, easy rollback
5. **Update Checklist**: Mark items complete as you go
6. **Document Issues**: Add notes about unexpected problems
7. **Take Breaks**: Follow estimated times, don't rush
8. **Ask for Help**: If stuck on a step for >30min, consult team
9. **Update Plan**: If reality differs from plan, update the plan
10. **Retrospective**: After completion, note what worked/didn't work

## Integration with Other Commands

### Before Planning
```bash
# 1. Generate tasks from code review
/generate_tasks

# 2. Create atomic plan for first task
FIRST_TASK=$(grep ",pending," tasks.csv | head -1 | cut -d',' -f1)
/atomic-plan $FIRST_TASK
```

### During Execution
```bash
# Monitor progress
watch -n 300 'grep "\[x\]" .claude/workspace/$TASK_ID/checklist-$TASK_ID.md | wc -l'
```

### After Completion
```bash
# Update task status
sed -i '' "s/$TASK_ID,\([^,]*\),pending,/$TASK_ID,\1,completed,/" tasks.csv

# Archive workspace
mv ".claude/workspace/$TASK_ID" ".claude/workspace/archive/${TASK_ID}-completed-$(date +%Y%m%d)"

# Generate next plan
NEXT_TASK=$(grep ",pending," tasks.csv | head -1 | cut -d',' -f1)
/atomic-plan $NEXT_TASK
```
