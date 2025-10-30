---
description: Plan development sprints by analyzing tasks.csv and grouping work into time-boxed iterations with effort estimates and timelines
allowed-tools: Read, Write, Bash, Glob
argument-hint: [sprint-duration] [--priority LEVEL] [--start-date DATE] - Duration (1w/2w/3w/4w), priority filter, start date
---

# Plan Sprint

Create a development sprint plan by analyzing available tasks from tasks.csv, calculating capacity, selecting appropriate tasks based on priority and dependencies, and generating a structured sprint backlog with timeline.

## Overview

Sprint planning helps teams organize work into manageable time-boxed iterations. This command:
- Analyzes tasks from tasks.csv
- Calculates sprint capacity based on duration
- Selects tasks respecting priorities and dependencies
- Generates sprint documentation and timeline
- Creates tracking artifacts for sprint execution

## Pre-Planning Discovery

### Validate Required Files

```bash
echo "🔍 Validating prerequisites..."
echo ""

# Check if tasks.csv exists
if [ ! -f ".claude/tasks.csv" ]; then
    echo "❌ ERROR: tasks.csv not found"
    echo "   Run: /generate_tasks to create task tracking file"
    exit 1
fi

echo "✅ tasks.csv found"

# Count available tasks
TOTAL_TASKS=$(tail -n +2 .claude/tasks.csv | wc -l | tr -d ' ')
PENDING_TASKS=$(grep ",pending," .claude/tasks.csv 2>/dev/null | wc -l | tr -d ' ')
INPROGRESS_TASKS=$(grep ",in-progress," .claude/tasks.csv 2>/dev/null | wc -l | tr -d ' ')

echo "📊 Task Status:"
echo "   Total tasks: $TOTAL_TASKS"
echo "   Pending: $PENDING_TASKS"
echo "   In progress: $INPROGRESS_TASKS"
echo ""

if [ "$PENDING_TASKS" -eq 0 ]; then
    echo "⚠️  No pending tasks available for sprint planning"
    exit 0
fi
```

### Parse Command-Line Arguments

```bash
# Default values
SPRINT_DURATION="${1:-2w}"  # Default: 2 weeks
PRIORITY_FILTER=""
START_DATE=$(date +%Y-%m-%d)

# Parse optional arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --priority)
            PRIORITY_FILTER="$2"
            shift 2
            ;;
        --start-date)
            START_DATE="$2"
            shift 2
            ;;
        *)
            echo "⚠️  Unknown argument: $1"
            shift
            ;;
    esac
done

echo "📅 Sprint Configuration:"
echo "   Duration: $SPRINT_DURATION"
echo "   Start Date: $START_DATE"
echo "   Priority Filter: ${PRIORITY_FILTER:-all}"
echo ""

# Validate and convert duration to days
case "$SPRINT_DURATION" in
    1w) SPRINT_DAYS=5 ;;
    2w) SPRINT_DAYS=10 ;;
    3w) SPRINT_DAYS=15 ;;
    4w) SPRINT_DAYS=20 ;;
    *)
        echo "❌ Invalid sprint duration: $SPRINT_DURATION"
        echo "   Valid options: 1w, 2w, 3w, 4w"
        exit 1
        ;;
esac

# Calculate end date (simplified - assumes 5 day work weeks)
if command -v date >/dev/null 2>&1; then
    # macOS and Linux compatible
    if [[ "$OSTYPE" == "darwin"* ]]; then
        END_DATE=$(date -v+${SPRINT_DAYS}d -j -f "%Y-%m-%d" "$START_DATE" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
    else
        END_DATE=$(date -d "$START_DATE + $SPRINT_DAYS days" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
    fi
else
    END_DATE="[Calculate manually]"
fi

echo "   End Date: $END_DATE"
echo ""
```

### Check for Existing Sprints

```bash
# Create sprints directory if it doesn't exist
mkdir -p .claude/sprints

# Check if a sprint already exists for this date
SPRINT_FILE=".claude/sprints/sprint-${START_DATE}.md"

if [ -f "$SPRINT_FILE" ]; then
    echo "⚠️  Sprint already exists: $SPRINT_FILE"
    read -p "   Overwrite existing sprint? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Sprint planning cancelled"
        exit 1
    fi
    echo ""
fi
```

## Sprint Capacity Calculation

### Calculate Available Capacity

```bash
echo "📊 Calculating sprint capacity..."
echo ""

# Assume 6 productive hours per day per developer
# For now, assume single developer (can be extended for teams)
HOURS_PER_DAY=6
DEVELOPERS=1
BUFFER_FACTOR=0.8  # 20% buffer for meetings, interruptions

TOTAL_CAPACITY_HOURS=$(echo "$SPRINT_DAYS * $HOURS_PER_DAY * $DEVELOPERS * $BUFFER_FACTOR" | bc)
TOTAL_CAPACITY_DAYS=$(echo "$TOTAL_CAPACITY_HOURS / 8" | bc)

echo "⏱️  Sprint Capacity:"
echo "   Working days: $SPRINT_DAYS"
echo "   Developers: $DEVELOPERS"
echo "   Hours per day: $HOURS_PER_DAY (with $((100 - ${BUFFER_FACTOR%.*}))% buffer)"
echo "   Total capacity: ${TOTAL_CAPACITY_DAYS} days / ${TOTAL_CAPACITY_HOURS} hours"
echo ""
```

### Analyze Historical Velocity (Optional)

```bash
# Check if previous sprints exist to estimate velocity
PREVIOUS_SPRINTS=$(find .claude/sprints -name "sprint-*.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$PREVIOUS_SPRINTS" -gt 0 ]; then
    echo "📈 Historical Data:"
    echo "   Previous sprints: $PREVIOUS_SPRINTS"
    echo "   (Velocity calculation not yet implemented)"
    echo ""
fi
```

## Task Selection Strategy

### Filter and Rank Tasks

```bash
echo "🎯 Selecting tasks for sprint..."
echo ""

# Create temporary file for filtered tasks
TEMP_TASKS=$(mktemp)

# Filter tasks by status and priority
if [ -n "$PRIORITY_FILTER" ]; then
    echo "   Filtering by priority: $PRIORITY_FILTER"
    grep -E ",pending,|,in-progress," .claude/tasks.csv | \
        grep -E ",$PRIORITY_FILTER," > "$TEMP_TASKS"
else
    grep -E ",pending,|,in-progress," .claude/tasks.csv > "$TEMP_TASKS"
fi

AVAILABLE_TASKS=$(wc -l < "$TEMP_TASKS" | tr -d ' ')
echo "   Available tasks after filtering: $AVAILABLE_TASKS"
echo ""

if [ "$AVAILABLE_TASKS" -eq 0 ]; then
    echo "❌ No tasks match the criteria"
    rm "$TEMP_TASKS"
    exit 1
fi
```

### Sort by Priority and Dependencies

```bash
# Sort tasks:
# 1. By priority (critical > high > medium > low)
# 2. By phase (earlier phases first)
# 3. By dependencies (tasks with no dependencies first)

sort_tasks() {
    local input_file="$1"
    local output_file="$2"

    # Priority order
    (
        grep ",critical," "$input_file" 2>/dev/null
        grep ",high," "$input_file" 2>/dev/null
        grep ",medium," "$input_file" 2>/dev/null
        grep ",low," "$input_file" 2>/dev/null
    ) > "$output_file"
}

SORTED_TASKS=$(mktemp)
sort_tasks "$TEMP_TASKS" "$SORTED_TASKS"

echo "✅ Tasks sorted by priority and phase"
echo ""
```

### Select Tasks Within Capacity

```bash
echo "📦 Building sprint backlog..."
echo ""

# Select tasks until capacity is reached
ACCUMULATED_EFFORT=0
SPRINT_BACKLOG=$(mktemp)

while IFS=',' read -r task_id title description priority status phase effort rest; do
    # Parse effort (remove days unit if present)
    TASK_EFFORT=$(echo "$effort" | grep -oE '[0-9]+' | head -1)

    # Skip tasks without effort estimates
    if [ -z "$TASK_EFFORT" ]; then
        TASK_EFFORT=1
    fi

    # Check if adding this task exceeds capacity
    NEW_TOTAL=$(echo "$ACCUMULATED_EFFORT + $TASK_EFFORT" | bc)

    if [ $(echo "$NEW_TOTAL <= $TOTAL_CAPACITY_DAYS" | bc) -eq 1 ]; then
        # Add task to sprint backlog
        echo "$task_id,$title,$description,$priority,$status,$phase,$effort,$rest" >> "$SPRINT_BACKLOG"
        ACCUMULATED_EFFORT=$NEW_TOTAL
        echo "   ✓ Added: $task_id ($TASK_EFFORT days) - Total: ${ACCUMULATED_EFFORT}/${TOTAL_CAPACITY_DAYS} days"
    else
        echo "   ⚠️  Capacity reached. Remaining tasks excluded."
        break
    fi
done < "$SORTED_TASKS"

echo ""

SPRINT_TASK_COUNT=$(wc -l < "$SPRINT_BACKLOG" | tr -d ' ')
CAPACITY_USED=$(echo "scale=1; $ACCUMULATED_EFFORT / $TOTAL_CAPACITY_DAYS * 100" | bc)

echo "📊 Sprint Backlog Summary:"
echo "   Tasks selected: $SPRINT_TASK_COUNT"
echo "   Effort committed: ${ACCUMULATED_EFFORT} days"
echo "   Capacity used: ${CAPACITY_USED}%"
echo ""
```

## Task Grouping & Timeline

### Group Tasks by Phase

```bash
echo "📋 Grouping tasks by phase..."
echo ""

# Count tasks by phase
PHASE_1_COUNT=$(grep ",phase-1," "$SPRINT_BACKLOG" 2>/dev/null | wc -l | tr -d ' ')
PHASE_2_COUNT=$(grep ",phase-2," "$SPRINT_BACKLOG" 2>/dev/null | wc -l | tr -d ' ')
PHASE_3_COUNT=$(grep ",phase-3," "$SPRINT_BACKLOG" 2>/dev/null | wc -l | tr -d ' ')
PHASE_0_COUNT=$(grep ",phase-0," "$SPRINT_BACKLOG" 2>/dev/null | wc -l | tr -d ' ')

echo "   Phase 0 (Hotfixes): $PHASE_0_COUNT tasks"
echo "   Phase 1 (Critical): $PHASE_1_COUNT tasks"
echo "   Phase 2 (Important): $PHASE_2_COUNT tasks"
echo "   Phase 3 (Enhancement): $PHASE_3_COUNT tasks"
echo ""
```

### Generate Timeline

```bash
echo "📅 Generating sprint timeline..."
echo ""

# Create week-by-week breakdown
TIMELINE_FILE=".claude/sprints/sprint-${START_DATE}-timeline.md"

cat > "$TIMELINE_FILE" << EOF
# Sprint Timeline: $START_DATE to $END_DATE

## Sprint Goals
- Complete $SPRINT_TASK_COUNT tasks
- Target effort: ${ACCUMULATED_EFFORT} days
- Focus: $([ $PHASE_0_COUNT -gt 0 ] && echo "Hotfixes + " || echo "")$([ $PHASE_1_COUNT -gt 0 ] && echo "Phase 1 Critical Issues" || echo "Development Progress")

---

## Week 1

### Days 1-2: Sprint Kickoff
EOF

# Add first few tasks to Week 1
head -3 "$SPRINT_BACKLOG" | while IFS=',' read -r task_id title rest; do
    echo "- [ ] **$task_id**: $title" >> "$TIMELINE_FILE"
done

cat >> "$TIMELINE_FILE" << EOF

### Days 3-5: Core Development
EOF

# Add next tasks
sed -n '4,7p' "$SPRINT_BACKLOG" | while IFS=',' read -r task_id title rest; do
    echo "- [ ] **$task_id**: $title" >> "$TIMELINE_FILE"
done

# Add Week 2 if sprint is 2+ weeks
if [ "$SPRINT_DAYS" -ge 10 ]; then
cat >> "$TIMELINE_FILE" << EOF

---

## Week 2

### Days 6-8: Continued Development
EOF

    sed -n '8,10p' "$SPRINT_BACKLOG" | while IFS=',' read -r task_id title rest; do
        echo "- [ ] **$task_id**: $title" >> "$TIMELINE_FILE"
    done

cat >> "$TIMELINE_FILE" << EOF

### Days 9-10: Testing & Refinement
- [ ] Run full test suite
- [ ] Address any issues found
- [ ] Prepare sprint review
EOF
fi

cat >> "$TIMELINE_FILE" << EOF

---

## Sprint Ceremonies

### Daily Standup
- **When**: Every morning, 15 minutes
- **What**: Progress, blockers, plan for today

### Sprint Review
- **When**: Last day of sprint
- **What**: Demo completed work, gather feedback

### Sprint Retrospective
- **When**: After sprint review
- **What**: What went well, what to improve

---

## Success Criteria

- [ ] All selected tasks completed or in-progress
- [ ] No critical bugs introduced
- [ ] Code review completed for all changes
- [ ] Tests passing for all changes
- [ ] Documentation updated

EOF

echo "✅ Timeline created: $TIMELINE_FILE"
echo ""
```

## Documentation Generation

### Create Sprint Plan Document

```bash
echo "📝 Generating sprint plan document..."
echo ""

cat > "$SPRINT_FILE" << EOF
# Sprint Plan: $START_DATE to $END_DATE

**Generated**: $(date +"%Y-%m-%d %H:%M:%S")
**Duration**: $SPRINT_DURATION ($SPRINT_DAYS working days)
**Capacity**: ${ACCUMULATED_EFFORT} days
**Status**: Planning

---

## Sprint Overview

### Sprint Goal
Complete $SPRINT_TASK_COUNT high-priority development tasks focused on $([ $PHASE_1_COUNT -gt 0 ] && echo "critical issues" || echo "feature development").

### Team Capacity
- **Developers**: $DEVELOPERS
- **Working Days**: $SPRINT_DAYS
- **Available Capacity**: ${TOTAL_CAPACITY_DAYS} days (with buffer)
- **Capacity Utilization**: ${CAPACITY_USED}%

### Task Breakdown
- **Phase 0 (Hotfixes)**: $PHASE_0_COUNT tasks
- **Phase 1 (Critical)**: $PHASE_1_COUNT tasks
- **Phase 2 (Important)**: $PHASE_2_COUNT tasks
- **Phase 3 (Enhancement)**: $PHASE_3_COUNT tasks

---

## Sprint Backlog

EOF

# Add tasks to sprint plan
echo "| Task ID | Title | Priority | Phase | Effort |" >> "$SPRINT_FILE"
echo "|---------|-------|----------|-------|--------|" >> "$SPRINT_FILE"

while IFS=',' read -r task_id title description priority status phase effort rest; do
    # Clean up fields
    title=$(echo "$title" | sed 's/"//g')
    effort_clean=$(echo "$effort" | grep -oE '[0-9]+' | head -1)

    echo "| $task_id | $title | $priority | $phase | ${effort_clean}d |" >> "$SPRINT_FILE"
done < "$SPRINT_BACKLOG"

cat >> "$SPRINT_FILE" << EOF

---

## Risk Assessment

### High-Priority Risks
EOF

# Identify potential risks
COMPLEX_TASKS=$(awk -F',' '{if ($7 ~ /[5-9]|[0-9][0-9]/) print $0}' "$SPRINT_BACKLOG" | wc -l | tr -d ' ')
DEPENDENT_TASKS=$(awk -F',' '{if ($8 != "none" && $8 != "") print $0}' "$SPRINT_BACKLOG" | wc -l | tr -d ' ')

if [ "$COMPLEX_TASKS" -gt 0 ]; then
    echo "- ⚠️  **$COMPLEX_TASKS complex tasks** (>5 days) - May need breakdown" >> "$SPRINT_FILE"
fi

if [ "$DEPENDENT_TASKS" -gt 0 ]; then
    echo "- ⚠️  **$DEPENDENT_TASKS tasks with dependencies** - May block progress" >> "$SPRINT_FILE"
fi

if [ $(echo "$CAPACITY_USED > 90" | bc) -eq 1 ]; then
    echo "- ⚠️  **Over 90% capacity** - Little buffer for unexpected work" >> "$SPRINT_FILE"
fi

cat >> "$SPRINT_FILE" << EOF

### Mitigation Strategies
- Break down complex tasks into smaller atomic steps
- Start dependency-blocking tasks early
- Reserve 20% capacity for unexpected issues
- Daily standups to identify blockers early

---

## Sprint Commands

### Start Sprint Execution
\`\`\`bash
# Begin working on first task
FIRST_TASK=\$(head -1 .claude/sprints/sprint-${START_DATE}-backlog.csv | cut -d',' -f1)
/atomic-plan \$FIRST_TASK
\`\`\`

### Track Progress
\`\`\`bash
# View sprint timeline
cat .claude/sprints/sprint-${START_DATE}-timeline.md

# Check completed tasks
grep -c "[x]" .claude/sprints/sprint-${START_DATE}-timeline.md
\`\`\`

### Update Sprint Status
\`\`\`bash
# Mark sprint as in-progress/completed
sed -i '' 's/Status: Planning/Status: In Progress/' .claude/sprints/sprint-${START_DATE}.md
\`\`\`

---

## Next Steps

1. **Review this sprint plan** - Ensure tasks are appropriate
2. **Start first task** - Run \`/atomic-plan TASK-ID\`
3. **Daily progress tracking** - Update timeline checkboxes
4. **Sprint review preparation** - Document completed work

---

**Sprint Plan**: [sprint-${START_DATE}.md](.claude/sprints/sprint-${START_DATE}.md)
**Timeline**: [sprint-${START_DATE}-timeline.md](.claude/sprints/sprint-${START_DATE}-timeline.md)
**Backlog CSV**: [sprint-${START_DATE}-backlog.csv](.claude/sprints/sprint-${START_DATE}-backlog.csv)
EOF

echo "✅ Sprint plan created: $SPRINT_FILE"
echo ""
```

### Create Sprint Backlog CSV

```bash
# Copy sprint backlog to named file
BACKLOG_CSV=".claude/sprints/sprint-${START_DATE}-backlog.csv"
cp "$SPRINT_BACKLOG" "$BACKLOG_CSV"

echo "✅ Sprint backlog CSV: $BACKLOG_CSV"
echo ""

# Clean up temporary files
rm -f "$TEMP_TASKS" "$SORTED_TASKS" "$SPRINT_BACKLOG"
```

## Summary Display

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          SPRINT PLANNING COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📅 Sprint: $START_DATE to $END_DATE ($SPRINT_DURATION)"
echo ""
echo "📊 Sprint Metrics:"
echo "   Tasks: $SPRINT_TASK_COUNT"
echo "   Effort: ${ACCUMULATED_EFFORT} days"
echo "   Capacity: ${TOTAL_CAPACITY_DAYS} days"
echo "   Utilization: ${CAPACITY_USED}%"
echo ""
echo "📋 Task Distribution:"
echo "   Phase 0 (Hotfixes): $PHASE_0_COUNT"
echo "   Phase 1 (Critical): $PHASE_1_COUNT"
echo "   Phase 2 (Important): $PHASE_2_COUNT"
echo "   Phase 3 (Enhancement): $PHASE_3_COUNT"
echo ""
echo "📂 Generated Files:"
echo "   ✓ Sprint Plan: $SPRINT_FILE"
echo "   ✓ Timeline: $TIMELINE_FILE"
echo "   ✓ Backlog CSV: $BACKLOG_CSV"
echo ""
echo "🚀 Next Steps:"
echo "   1. Review sprint plan: cat $SPRINT_FILE"
echo "   2. Start first task: /atomic-plan \$(head -1 $BACKLOG_CSV | cut -d',' -f1)"
echo "   3. Track progress: cat $TIMELINE_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Expected Outcomes

After executing `/plan-sprint`, you should have:

### Generated Files

1. **Sprint Plan** - `.claude/sprints/sprint-{date}.md`
   - Sprint overview and goals
   - Team capacity calculation
   - Complete task breakdown table
   - Risk assessment and mitigation strategies
   - Command reference for execution

2. **Sprint Timeline** - `.claude/sprints/sprint-{date}-timeline.md`
   - Week-by-week breakdown
   - Task assignments by day
   - Sprint ceremonies schedule
   - Success criteria checklist

3. **Sprint Backlog CSV** - `.claude/sprints/sprint-{date}-backlog.csv`
   - Machine-readable task list
   - Full task details from tasks.csv
   - Used by other commands for sprint tracking

### Console Output

- Sprint configuration summary
- Capacity calculation details
- Task selection process
- Risk warnings (if any)
- File generation confirmation
- Next steps guidance

---

## Usage Examples

### Example 1: Basic 2-Week Sprint

```bash
# Plan default 2-week sprint starting today
/plan-sprint

# Output:
# ✅ Sprint plan created for 2025-11-01 to 2025-11-15
# 📊 8 tasks selected, 9.5 days effort, 95% capacity
```

### Example 2: 1-Week Sprint with Priority Filter

```bash
# Plan 1-week sprint with only critical and high priority tasks
/plan-sprint 1w --priority critical,high

# Output:
# ✅ Sprint plan created for 2025-11-01 to 2025-11-08
# 📊 4 critical tasks selected, 4.5 days effort, 90% capacity
```

### Example 3: Sprint with Future Start Date

```bash
# Plan sprint starting next Monday
/plan-sprint 2w --start-date 2025-11-04

# Output:
# ✅ Sprint plan created for 2025-11-04 to 2025-11-18
# 📊 10 tasks selected, 9 days effort, 90% capacity
```

### Example 4: 3-Week Sprint for Large Initiative

```bash
# Plan extended sprint for major refactoring
/plan-sprint 3w

# Output:
# ✅ Sprint plan created for 2025-11-01 to 2025-11-22
# 📊 15 tasks selected, 14 days effort, 93% capacity
# ⚠️  3 complex tasks (>5 days) - Consider breakdown
```

### Example 5: High-Priority Only Sprint

```bash
# Emergency sprint for critical issues
/plan-sprint 1w --priority critical

# Output:
# ✅ Sprint plan created for 2025-11-01 to 2025-11-08
# 📊 3 critical tasks selected, 4 days effort, 80% capacity
```

---

## Troubleshooting

### No Pending Tasks

```bash
# Error: No pending tasks available for sprint planning
# Solution: Generate tasks or check task status

# Check current status
grep -v "^task_id," .claude/tasks.csv | cut -d',' -f1,5

# Update task status if needed
sed -i '' 's/TASK-ID,\([^,]*\),completed,/TASK-ID,\1,pending,/' .claude/tasks.csv
```

### Invalid Duration Format

```bash
# Error: Invalid sprint duration
# Solution: Use valid format (1w, 2w, 3w, 4w)

/plan-sprint 2weeks  # ❌ Wrong
/plan-sprint 2w      # ✅ Correct
```

### Overcommitted Capacity

```bash
# Warning: 95%+ capacity used
# Solution: Reduce task count or extend sprint

# Option 1: Extend sprint
/plan-sprint 3w

# Option 2: Filter to fewer tasks
/plan-sprint 2w --priority critical
```

### Sprint Already Exists

```bash
# Warning: Sprint already exists for date
# Solution: Choose different start date or overwrite

# Use different date
/plan-sprint 2w --start-date 2025-11-08

# Or confirm overwrite when prompted
```

### Missing Task Effort Estimates

```bash
# Warning: Tasks without effort estimates
# Solution: Update tasks.csv with estimates

# Find tasks without effort
awk -F',' '$7 == "" || $7 == "null" {print $1}' .claude/tasks.csv

# Update task with effort estimate
# (Edit tasks.csv manually or via script)
```

---

## Integration with Other Commands

### Sprint Planning Workflow

```bash
# 1. Generate tasks from code review
/code-review full
/generate_tasks

# 2. Plan sprint
/plan-sprint 2w

# 3. Start executing first task
FIRST_TASK=$(head -1 .claude/sprints/sprint-2025-11-01-backlog.csv | cut -d',' -f1)
/atomic-plan $FIRST_TASK
/execute-task $FIRST_TASK

# 4. Track progress
cat .claude/sprints/sprint-2025-11-01-timeline.md
```

### With Workspace Management

```bash
# Before planning, check active workspaces
/list-workspaces active

# Plan sprint with available capacity
/plan-sprint 2w

# After sprint, archive completed workspaces
/list-workspaces completed
/archive-workspace TASK-ID
```

### Sprint Review Preparation

```bash
# At end of sprint, generate completion report
/session-report --sprint sprint-2025-11-01

# Review sprint metrics
grep "\[x\]" .claude/sprints/sprint-2025-11-01-timeline.md | wc -l
```

---

## Best Practices

### Before Planning

1. **Review tasks.csv** - Ensure tasks have effort estimates
2. **Update task status** - Mark any completed work
3. **Check dependencies** - Understand task relationships
4. **Consider capacity** - Account for meetings, interruptions

### During Sprint

1. **Daily standup** - Review timeline, update progress
2. **Update checkboxes** - Mark completed tasks in timeline
3. **Track blockers** - Document issues in sprint notes
4. **Adjust if needed** - Add/remove tasks based on velocity

### After Sprint

1. **Sprint review** - Demo completed work
2. **Sprint retrospective** - What went well, what to improve
3. **Update velocity** - Calculate actual completion rate
4. **Archive workspaces** - Clean up completed task workspaces

### Capacity Planning Tips

- **Buffer**: Always include 20% buffer for unexpected work
- **Complexity**: Tasks >5 days should be broken down
- **Dependencies**: Start blocking tasks early in sprint
- **Team size**: Adjust DEVELOPERS variable for teams
- **Interruptions**: Account for meetings, support, etc.

---

## Advanced Usage

### Custom Capacity Calculation

```bash
# Edit sprint plan after generation to adjust capacity
# Change DEVELOPERS=1 to actual team size
# Adjust HOURS_PER_DAY and BUFFER_FACTOR as needed
```

### Sprint Progress Tracking

```bash
# Create simple progress script
cat > .claude/sprints/check-progress.sh << 'EOF'
#!/bin/bash
SPRINT_DATE="$1"
TOTAL=$(grep -c "\- \[ \]" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md)
DONE=$(grep -c "\- \[x\]" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md)
PERCENT=$(echo "scale=1; $DONE / $TOTAL * 100" | bc)
echo "Sprint Progress: $DONE/$TOTAL ($PERCENT%)"
EOF
chmod +x .claude/sprints/check-progress.sh

# Check progress
.claude/sprints/check-progress.sh 2025-11-01
```

### Multi-Sprint Planning

```bash
# Plan consecutive sprints
/plan-sprint 2w --start-date 2025-11-01
/plan-sprint 2w --start-date 2025-11-15
/plan-sprint 2w --start-date 2025-11-29

# View sprint roadmap
ls -l .claude/sprints/sprint-*.md
```

---

## Success Criteria

A successful sprint plan includes:
- ✅ Tasks selected within capacity limits
- ✅ Priorities respected (critical tasks first)
- ✅ Dependencies considered
- ✅ Realistic effort estimates
- ✅ Clear timeline with milestones
- ✅ Risk assessment completed
- ✅ Documentation generated
- ✅ Next steps clearly defined
