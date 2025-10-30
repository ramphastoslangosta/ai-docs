# Usage Example: /plan-sprint

Complete guide to using the `/plan-sprint` command for organizing development work into time-boxed iterations.

---

## Basic Usage

### Scenario 1: Standard 2-Week Sprint

```bash
# Plan default 2-week sprint starting today
/plan-sprint
```

**Expected Output:**
```
🔍 Validating prerequisites...
✅ tasks.csv found
📊 Task Status:
   Total tasks: 24
   Pending: 18
   In progress: 2

📅 Sprint Configuration:
   Duration: 2w
   Start Date: 2025-11-01
   End Date: 2025-11-15
   Priority Filter: all

📊 Calculating sprint capacity...
⏱️  Sprint Capacity:
   Working days: 10
   Developers: 1
   Hours per day: 6 (with 20% buffer)
   Total capacity: 6 days / 48 hours

🎯 Selecting tasks for sprint...
   Available tasks after filtering: 18
✅ Tasks sorted by priority and phase

📦 Building sprint backlog...
   ✓ Added: TASK-20251001-001 (1 days) - Total: 1/6 days
   ✓ Added: TASK-20251001-002 (2 days) - Total: 3/6 days
   ✓ Added: TASK-20251001-003 (1 days) - Total: 4/6 days
   ✓ Added: TASK-20251001-004 (2 days) - Total: 6/6 days

📊 Sprint Backlog Summary:
   Tasks selected: 4
   Effort committed: 6 days
   Capacity used: 100.0%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          SPRINT PLANNING COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Sprint: 2025-11-01 to 2025-11-15 (2w)

📊 Sprint Metrics:
   Tasks: 4
   Effort: 6 days
   Capacity: 6 days
   Utilization: 100.0%

📂 Generated Files:
   ✓ Sprint Plan: .claude/sprints/sprint-2025-11-01.md
   ✓ Timeline: .claude/sprints/sprint-2025-11-01-timeline.md
   ✓ Backlog CSV: .claude/sprints/sprint-2025-11-01-backlog.csv

🚀 Next Steps:
   1. Review sprint plan: cat .claude/sprints/sprint-2025-11-01.md
   2. Start first task: /atomic-plan TASK-20251001-001
   3. Track progress: cat .claude/sprints/sprint-2025-11-01-timeline.md
```

---

## Advanced Usage

### Scenario 2: Critical Issues Sprint (1 Week)

When you need to focus on urgent fixes:

```bash
# Plan 1-week sprint with only critical priority tasks
/plan-sprint 1w --priority critical
```

**Use Case:**
- Emergency production issues
- Security vulnerabilities
- Critical bug fixes
- High-severity incidents

**Result:**
- Shorter duration (5 working days)
- Only critical tasks selected
- Focused sprint with clear priorities
- Quick turnaround time

---

### Scenario 3: Mixed Priority Sprint with High Urgency

```bash
# Plan sprint with critical and high priority tasks
/plan-sprint 2w --priority critical,high
```

**Use Case:**
- Balancing urgent issues with important work
- Clearing technical debt backlog
- Pre-release sprint with critical fixes and features
- Team has capacity for both urgent and important work

**Result:**
- Includes both critical and high priority tasks
- Filters out medium/low priority work
- Focused on highest-value items
- Better capacity utilization

---

### Scenario 4: Future Sprint Planning

```bash
# Plan sprint starting next Monday
/plan-sprint 2w --start-date 2025-11-04
```

**Use Case:**
- Planning ahead for next iteration
- Aligning with team's sprint cadence
- Preparing sprint backlog before sprint starts
- Coordinating with remote teams in different timezones

**Result:**
- Sprint scheduled for future date
- Time to prepare and refine tasks
- Team can review and adjust before start
- Better sprint preparation

---

### Scenario 5: Extended Sprint for Large Initiative

```bash
# Plan 3-week sprint for major refactoring
/plan-sprint 3w
```

**Use Case:**
- Large refactoring effort
- Complex feature with many dependencies
- Team velocity is lower than usual
- Multiple phases need completion

**Expected Warning:**
```
⚠️  3 complex tasks (>5 days) - Consider breakdown
⚠️  5 tasks with dependencies - May block progress
```

**Result:**
- More tasks included (15+ tasks)
- Higher total effort (14 days)
- Risk assessment highlights complex work
- Mitigation strategies provided

---

## Integration Workflows

### Workflow 1: Complete Development Cycle

```bash
# 1. Analyze codebase
/code-review full

# 2. Generate tasks from findings
/generate_tasks

# 3. Plan sprint
/plan-sprint 2w

# 4. Review sprint plan
cat .claude/sprints/sprint-2025-11-01.md

# 5. Start executing first task
FIRST_TASK=$(head -1 .claude/sprints/sprint-2025-11-01-backlog.csv | cut -d',' -f1)
/atomic-plan $FIRST_TASK

# 6. Execute task step-by-step
/execute-task $FIRST_TASK
```

---

### Workflow 2: Pre-Sprint Planning

```bash
# 1. Review current workspace status
/list-workspaces active

# 2. Archive completed work
/archive-workspace COMPLETED-TASK-ID

# 3. Check available tasks
grep ",pending," .claude/tasks.csv | wc -l

# 4. Plan next sprint
/plan-sprint 2w --start-date $(date -v+7d +%Y-%m-%d)

# 5. Review and adjust
cat .claude/sprints/sprint-*.md
```

---

### Workflow 3: Mid-Sprint Adjustment

```bash
# Check sprint progress
SPRINT_DATE="2025-11-01"
cat .claude/sprints/sprint-${SPRINT_DATE}-timeline.md

# Count completed tasks
COMPLETED=$(grep -c "\[x\]" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md)
echo "Completed: $COMPLETED tasks"

# If ahead of schedule, plan next sprint early
/plan-sprint 2w --start-date 2025-11-15

# If behind, re-plan with fewer tasks
/plan-sprint 2w --priority critical
```

---

## Sprint Execution Examples

### Daily Progress Tracking

```bash
# Morning: Check today's tasks
SPRINT_DATE="2025-11-01"
grep "### Days $(date +%d)" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md -A 5

# Start task
/execute-task TASK-20251001-001

# End of day: Update progress
# Mark completed tasks with [x] in timeline file
# Update sprint plan status if needed
```

---

### Sprint Review Preparation

```bash
# Generate sprint summary
SPRINT_DATE="2025-11-01"

echo "=== Sprint Review: $SPRINT_DATE ==="
echo ""

# Count completions
TOTAL=$(grep -c "\- \[ \]" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md)
DONE=$(grep -c "\- \[x\]" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md)
PERCENT=$(echo "scale=1; $DONE / $TOTAL * 100" | bc)

echo "Sprint Progress: $DONE/$TOTAL tasks ($PERCENT%)"
echo ""

# List completed tasks
echo "Completed Tasks:"
grep "\[x\]" .claude/sprints/sprint-${SPRINT_DATE}-timeline.md

# Generate session report
/session-report --sprint sprint-${SPRINT_DATE}
```

---

## Troubleshooting Examples

### Issue: No tasks available

```bash
# Problem: No pending tasks found
/plan-sprint
# Error: No pending tasks available for sprint planning

# Solution 1: Check task status
grep -v "^task_id," .claude/tasks.csv | cut -d',' -f1,5

# Solution 2: Generate new tasks
/code-review full
/generate_tasks

# Solution 3: Update task status manually
# (Edit .claude/tasks.csv to change status from completed to pending)
```

---

### Issue: Sprint overwrites existing plan

```bash
# Problem: Sprint already exists warning
/plan-sprint 2w --start-date 2025-11-01
# Warning: Sprint already exists: .claude/sprints/sprint-2025-11-01.md

# Solution 1: Use different start date
/plan-sprint 2w --start-date 2025-11-08

# Solution 2: Archive old sprint first
mv .claude/sprints/sprint-2025-11-01.md .claude/sprints/archive/

# Solution 3: Confirm overwrite when prompted
# (Press 'y' when asked to overwrite)
```

---

### Issue: Capacity too low, few tasks selected

```bash
# Problem: Only 2 tasks fit in sprint
/plan-sprint 1w
# Sprint Backlog Summary: 2 tasks, 4 days effort

# Solution 1: Extend sprint duration
/plan-sprint 2w

# Solution 2: Adjust capacity assumptions
# (Edit generated sprint plan, increase DEVELOPERS or HOURS_PER_DAY)

# Solution 3: Break down large tasks
# (Edit tasks.csv to split large tasks into smaller ones)
```

---

## Best Practices

### Before Planning

```bash
# 1. Update task estimates
# Review tasks.csv and ensure effort estimates are realistic

# 2. Check dependencies
awk -F',' '$8 != "none" && $8 != "" {print $1, "depends on", $8}' .claude/tasks.csv

# 3. Review team capacity
# Consider: holidays, vacations, meetings, support duties

# 4. Clean up old sprints
ls -l .claude/sprints/
mv .claude/sprints/sprint-old-*.md .claude/sprints/archive/
```

---

### During Sprint

```bash
# Daily standup script
cat > daily-standup.sh << 'EOF'
#!/bin/bash
SPRINT=$(ls -t .claude/sprints/sprint-*.md | head -1 | sed 's|.claude/sprints/sprint-||;s|.md||')
echo "Daily Standup: $(date +%Y-%m-%d)"
echo ""
echo "Sprint: $SPRINT"
echo "Progress: $(grep -c '\[x\]' .claude/sprints/sprint-${SPRINT}-timeline.md)/$(grep -c '\[ \]' .claude/sprints/sprint-${SPRINT}-timeline.md) tasks"
echo ""
echo "Today's focus:"
grep "### Days $(date +%d)" .claude/sprints/sprint-${SPRINT}-timeline.md -A 5
EOF
chmod +x daily-standup.sh

# Run daily
./daily-standup.sh
```

---

### After Sprint

```bash
# 1. Sprint retrospective
echo "Sprint Retrospective: $(date)" > sprint-retro.md
echo "" >> sprint-retro.md
echo "## What went well:" >> sprint-retro.md
echo "- [Add successes]" >> sprint-retro.md
echo "" >> sprint-retro.md
echo "## What to improve:" >> sprint-retro.md
echo "- [Add improvements]" >> sprint-retro.md

# 2. Archive sprint
mkdir -p .claude/sprints/archive
mv .claude/sprints/sprint-2025-11-01* .claude/sprints/archive/

# 3. Update velocity
# Calculate actual velocity for future planning
# (Compare estimated vs actual completion time)

# 4. Clean up workspaces
/cleanup-workspaces --dry-run
/cleanup-workspaces
```

---

## Tips & Tricks

### Custom Capacity for Teams

Edit sprint plan after generation:

```bash
# Open sprint plan
vim .claude/sprints/sprint-2025-11-01.md

# Modify capacity calculation:
# DEVELOPERS=3  # Change from 1 to 3
# HOURS_PER_DAY=7  # Increase productive hours
```

---

### Sprint Progress Dashboard

Create simple progress tracker:

```bash
cat > sprint-progress.sh << 'EOF'
#!/bin/bash
SPRINT="${1:-$(ls -t .claude/sprints/sprint-*.md | head -1 | sed 's|.claude/sprints/sprint-||;s|.md||')}"

TOTAL=$(grep -c "\- \[ \]" .claude/sprints/sprint-${SPRINT}-timeline.md)
DONE=$(grep -c "\- \[x\]" .claude/sprints/sprint-${SPRINT}-timeline.md)
PERCENT=$(echo "scale=1; $DONE / $TOTAL * 100" | bc)

echo "Sprint: $SPRINT"
echo "Progress: $DONE/$TOTAL ($PERCENT%)"
echo ""
printf "["
for i in $(seq 1 20); do
    if [ $(echo "$i * 5 <= $PERCENT" | bc) -eq 1 ]; then
        printf "█"
    else
        printf "░"
    fi
done
printf "] ${PERCENT}%%\n"
EOF
chmod +x sprint-progress.sh

# Use it
./sprint-progress.sh
```

---

## Related Commands

- `/generate_tasks` - Generate tasks before sprint planning
- `/atomic-plan` - Create detailed plans for sprint tasks
- `/execute-task` - Execute planned tasks step-by-step
- `/list-workspaces` - Check active work before planning
- `/session-report` - Generate sprint completion report

---

## Additional Resources

- Sprint Planning Guide: `.claude/docs/sprint-planning-guide.md`
- Task Management: `.claude/CLAUDE.md#task-tracking-system`
- Workflow Documentation: `.claude/CLAUDE.md#common-workflows`
