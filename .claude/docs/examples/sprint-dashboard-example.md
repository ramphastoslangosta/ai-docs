# Sprint Dashboard Usage Examples

Complete guide with real-world examples for using the `/sprint-dashboard` command.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [Integration Workflows](#integration-workflows)
- [Troubleshooting Scenarios](#troubleshooting-scenarios)
- [Best Practices](#best-practices)

---

## Basic Usage

### Example 1: Generate Dashboard for Latest Sprint

**Scenario**: You have an active sprint and want to visualize current progress.

```bash
# Generate dashboard using latest sprint data
/sprint-dashboard
```

**Expected Output**:
```
Generating sprint dashboard...

Using latest sprint: 2025-10-30

Sprint files validated
Theme: factory
Auto-refresh: 30s

Output: .claude/sprints/dashboards/sprint-2025-10-30-dashboard.html

Collecting sprint data...
   Sprint backlog: 10 tasks
   Status distribution:
      Backlog: 2
      In Progress: 3
      Testing: 2
      Review: 1
      Complete: 2

Sprint progress: 20% (2 of 10)
Timeline progress: 15 of 50 items

Git available: Current branch: feature/sprint-oct-30

Building task cards...
Task cards built

Finalizing dashboard...
Dashboard finalized

Validating dashboard...
Dashboard size: 245K
HTML structure: valid

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          SPRINT DASHBOARD GENERATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sprint: 2025-10-30

Sprint Progress:
   Total Tasks: 10
   Completed: 2 (20%)
   In Progress: 3
   Testing: 2
   Review: 1
   Backlog: 2

Dashboard:
   File: .claude/sprints/dashboards/sprint-2025-10-30-dashboard.html
   Size: 245K
   Theme: factory
   Auto-refresh: 30s

View Dashboard:
   file:///Users/rafaellang/ai-docs/.claude/sprints/dashboards/sprint-2025-10-30-dashboard.html

Tip: Use --open flag to open automatically in browser

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**What Happens**:
1. Command finds latest sprint file in `.claude/sprints/`
2. Reads sprint backlog CSV and tasks.csv for current status
3. Generates HTML with embedded CSS/JavaScript
4. Creates task cards for each development stage
5. Saves to `.claude/sprints/dashboards/` directory
6. Displays summary with file path

**When to Use**: Daily sprint work, standup meetings, quick progress checks

---

### Example 2: Open Dashboard Automatically in Browser

**Scenario**: You want to view the dashboard immediately after generation.

```bash
# Generate and open in default browser
/sprint-dashboard --open
```

**Expected Behavior**:
- Dashboard generates as normal
- Browser automatically opens with the dashboard
- Factory view displays all tasks in their current stations
- Auto-refresh countdown begins (30 seconds)

**Visual Result**:
```
┌─────────────────────────────────────────────────────────────┐
│  AI Software Factory Dashboard                    Sprint: 2025-10-30 │
├─────────────────────────────────────────────────────────────┤
│  Progress: 20%  │  In Progress: 3  │  Testing: 2  │  ...   │
├─────────────────────────────────────────────────────────────┤
│  [Filter: Priority] [Filter: Phase] [Search: ________]      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────┐  ┌──────────┐  ┌────────┐  ┌────────┐  ┌────────┐│
│  │Back- │  │In        │  │Testing │  │Review  │  │Complete││
│  │log   │→→│Progress  │→→│        │→→│        │→→│        ││
│  │      │  │          │  │        │  │        │  │        ││
│  │ [2]  │  │ [3]      │  │ [2]    │  │ [1]    │  │ [2]    ││
│  │      │  │          │  │        │  │        │  │        ││
│  │ Task │  │ Task     │  │ Task   │  │ Task   │  │ Task   ││
│  │ Card │  │ Card     │  │ Card   │  │ Card   │  │ Card   ││
│  └──────┘  └──────────┘  └────────┘  └────────┘  └────────┘│
│  ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~   ~~~~~~~~   ~~~~~~~~    │
│             (Animated Conveyor Belts)                        │
└─────────────────────────────────────────────────────────────┘
```

**When to Use**: Sprint demos, team meetings, personal monitoring

---

### Example 3: Specific Sprint with Custom Refresh Rate

**Scenario**: You want to monitor a past sprint or upcoming sprint with faster updates.

```bash
# Generate dashboard for specific sprint with 15-second refresh
/sprint-dashboard 2025-11-01 --auto-refresh 15
```

**Use Case**: Active development sessions where task status changes frequently.

**Configuration**:
- Sprint date: 2025-11-01
- Auto-refresh: Every 15 seconds
- Theme: factory (default)

**When to Use**: Pair programming, mob programming, active sprint execution

---

## Advanced Usage

### Example 4: Complete Configuration with All Options

**Scenario**: Maximum customization for a sprint review presentation.

```bash
# Full configuration
/sprint-dashboard 2025-10-30 --auto-refresh 30 --theme factory --open
```

**Breakdown**:
- `2025-10-30` - Specific sprint date
- `--auto-refresh 30` - Refresh every 30 seconds
- `--theme factory` - Use factory visual theme
- `--open` - Open in browser immediately

**Result**: Professional dashboard ready for stakeholder presentation.

---

### Example 5: Disable Auto-Refresh for Static View

**Scenario**: Generate a snapshot for documentation or archival.

```bash
# Set refresh to 0 to disable
/sprint-dashboard --auto-refresh 0
```

**Use Case**: Sprint retrospective, end-of-sprint report, screenshot capture.

**Benefit**: Page won't reload, can be saved as PDF or screenshot.

---

### Example 6: Multiple Sprint Dashboards

**Scenario**: Compare progress across multiple sprints.

```bash
# Generate dashboards for last 3 sprints
/sprint-dashboard 2025-10-15
/sprint-dashboard 2025-10-29
/sprint-dashboard 2025-11-12

# Open all in separate tabs
open .claude/sprints/dashboards/sprint-2025-10-15-dashboard.html
open .claude/sprints/dashboards/sprint-2025-10-29-dashboard.html
open .claude/sprints/dashboards/sprint-2025-11-12-dashboard.html
```

**Analysis**: Side-by-side comparison of sprint velocity and completion rates.

---

## Integration Workflows

### Workflow 1: Complete Sprint Planning to Execution

**Scenario**: Full sprint lifecycle with dashboard tracking.

```bash
# Step 1: Plan sprint
/plan-sprint 2w

# Step 2: Generate initial dashboard
/sprint-dashboard --open

# Step 3: Start first task
FIRST_TASK=$(head -1 .claude/sprints/sprint-2025-10-30-backlog.csv | cut -d',' -f1)
/atomic-plan $FIRST_TASK

# Step 4: Execute task
/execute-task $FIRST_TASK

# Step 5: Refresh dashboard (auto-refreshes, or regenerate)
/sprint-dashboard

# Repeat steps 3-5 for remaining tasks
```

**Flow Diagram**:
```
Plan Sprint → Generate Dashboard → Execute Tasks → Monitor Progress
    ↓              ↓                    ↓              ↓
 tasks.csv    HTML Dashboard      Update Status  Auto-Refresh
```

---

### Workflow 2: Daily Standup Routine

**Scenario**: Morning standup meeting with team.

```bash
# Morning routine
/sprint-dashboard --open

# Review in meeting:
# 1. What was completed yesterday? (Check "Complete" station)
# 2. What's in progress today? (Check "In Progress" station)
# 3. Any blockers? (Check "Testing" and "Review" stations for stuck tasks)

# Use filters during meeting:
# - Filter by priority: "critical" to review urgent items
# - Search by team member name if visible in task descriptions
# - Click task cards to see details
```

**Meeting Flow**:
1. Open dashboard on shared screen
2. Walk through each station left to right
3. Discuss blockers (tasks stuck in testing/review)
4. Assign new work (backlog → in progress)

---

### Workflow 3: Sprint Review Preparation

**Scenario**: End of sprint, preparing demo for stakeholders.

```bash
# Generate final sprint dashboard
/sprint-dashboard --auto-refresh 0 --open

# Generate session report for metrics
/session-report docs/sprint-reports/sprint-$(date +%Y-%m-%d) --include-git

# Review completed work
grep -A 2 "list-complete" .claude/sprints/dashboards/sprint-*.html

# Take screenshots
# 1. Full dashboard view
# 2. Completed tasks station
# 3. Metrics panel

# Archive sprint dashboard
mkdir -p .claude/sprints/archive
cp .claude/sprints/dashboards/sprint-$(date +%Y-%m-%d)-dashboard.html \
   .claude/sprints/archive/sprint-$(date +%Y-%m-%d)-final.html
```

---

### Workflow 4: Bottleneck Detection

**Scenario**: Tasks piling up in testing or review stages.

```bash
# Generate dashboard
/sprint-dashboard --open

# Observe the dashboard:
# - Is "Testing" station overloaded? (Many cards)
# - Is "Review" station growing? (Cards stuck)
# - Is "In Progress" empty? (No active development)

# Take action:
# If testing is bottleneck:
echo "Testing bottleneck detected"
# Pair testers with developers
# Automate more tests

# If review is bottleneck:
echo "Review bottleneck detected"
# Schedule code review sessions
# Implement review rotation
```

**Visual Indicators**:
- Station with 4+ cards → Potential bottleneck
- Station with 0 cards → Process gap
- Tasks not moving → Investigate blockers

---

## Troubleshooting Scenarios

### Scenario 1: No Sprint Data Available

**Problem**:
```bash
/sprint-dashboard

# Output:
# ERROR: No sprints found
#    Run: /plan-sprint to create a sprint
```

**Solution**:
```bash
# Create a sprint first
/plan-sprint 2w

# Then generate dashboard
/sprint-dashboard
```

---

### Scenario 2: Dashboard Shows Empty Stations

**Problem**: All stations show "No tasks in [stage]"

**Diagnosis**:
```bash
# Check if sprint backlog exists
ls -la .claude/sprints/sprint-*-backlog.csv

# Check task status in tasks.csv
grep "TASK-ID" .claude/tasks.csv
```

**Solution**:
```bash
# Verify tasks have correct status values
# Status must be: pending, in-progress, testing, review, or completed

# Update task status if needed
sed -i '' 's/TASK-20251030-001,\([^,]*\),pending,/TASK-20251030-001,\1,in-progress,/' .claude/tasks.csv

# Regenerate dashboard
/sprint-dashboard
```

---

### Scenario 3: Dashboard Doesn't Refresh

**Problem**: Auto-refresh counter doesn't count down or page doesn't reload.

**Diagnosis**:
- Open browser console (F12)
- Check for JavaScript errors
- Verify browser allows JavaScript

**Solution**:
```bash
# Regenerate dashboard
/sprint-dashboard

# If problem persists, disable auto-refresh
/sprint-dashboard --auto-refresh 0

# Manually refresh browser (F5) as needed
```

---

### Scenario 4: Task Cards Not Clickable

**Problem**: Clicking task cards doesn't open modal.

**Diagnosis**: JavaScript function not loaded.

**Solution**:
1. Refresh page (F5)
2. Check browser console for errors
3. Regenerate dashboard: `/sprint-dashboard`
4. Try different browser

---

## Best Practices

### Practice 1: Keep Dashboard Open During Work

**Setup**:
```bash
# Generate dashboard with auto-refresh
/sprint-dashboard --auto-refresh 30 --open

# Position browser window:
# - Second monitor (recommended)
# - Half-screen split with editor
# - Separate desktop/workspace
```

**Benefits**:
- Real-time visibility of sprint progress
- Immediate feedback on task status changes
- Motivation boost seeing tasks move to "Complete"

---

### Practice 2: Update Task Status Regularly

**Workflow**:
```bash
# When starting a task
sed -i '' 's/TASK-ID,\([^,]*\),pending,/TASK-ID,\1,in-progress,/' .claude/tasks.csv

# When moving to testing
sed -i '' 's/TASK-ID,\([^,]*\),in-progress,/TASK-ID,\1,testing,/' .claude/tasks.csv

# When ready for review
sed -i '' 's/TASK-ID,\([^,]*\),testing,/TASK-ID,\1,review,/' .claude/tasks.csv

# When completed
sed -i '' 's/TASK-ID,\([^,]*\),review,/TASK-ID,\1,completed,/' .claude/tasks.csv

# Dashboard will auto-update on next refresh
```

---

### Practice 3: Use Dashboard for Standups

**Meeting Structure**:
1. **Share screen** with dashboard
2. **Walk through stations** left to right:
   - Backlog: What's queued
   - In Progress: Who's working on what
   - Testing: What needs testing help
   - Review: What needs code review
   - Complete: What was finished
3. **Filter by priority** to highlight critical items
4. **Click tasks** to show details
5. **Identify blockers** visually (stuck cards)

---

### Practice 4: Archive Sprint Dashboards

**End of Sprint Routine**:
```bash
# Generate final dashboard (no auto-refresh)
/sprint-dashboard --auto-refresh 0

# Archive it
SPRINT_DATE=$(date +%Y-%m-%d)
mkdir -p .claude/sprints/archive
cp .claude/sprints/dashboards/sprint-${SPRINT_DATE}-dashboard.html \
   .claude/sprints/archive/sprint-${SPRINT_DATE}-final.html

# Take screenshot
# (Use browser dev tools or screenshot tool)

# Document completion in retrospective
echo "Sprint completed: ${SPRINT_DATE}" >> .claude/sprints/RETROSPECTIVES.md
```

---

### Practice 5: Combine with Other Reports

**Comprehensive Sprint Analysis**:
```bash
# Generate all reports at sprint end
/sprint-dashboard --auto-refresh 0 --open
/session-report docs/sprint-reports --include-git

# Create sprint summary
cat > .claude/sprints/sprint-summary-$(date +%Y-%m-%d).md << EOF
# Sprint Summary: $(date +%Y-%m-%d)

## Links
- [Sprint Dashboard](./dashboards/sprint-$(date +%Y-%m-%d)-dashboard.html)
- [Session Report](../../docs/sprint-reports/session-$(date +%Y%m%d)-*.html)

## Metrics
- Total Tasks: $(grep "TOTAL_TASKS_PLACEHOLDER" sprint-dashboard.md | wc -l)
- Completed: X
- Velocity: Y tasks/day

## Highlights
- Key achievements
- Challenges faced
- Learnings

## Action Items
- [ ] Follow-up task 1
- [ ] Follow-up task 2
EOF
```

---

### Practice 6: Responsive Monitoring

**Multi-Device Setup**:
```bash
# Desktop: Full dashboard with all features
/sprint-dashboard --open

# Tablet/Phone: Mobile-responsive view
# Open same URL on mobile device
# Dashboard adapts to smaller screen:
# - Stations stack vertically
# - Metrics show 2 per row
# - Touch-friendly buttons
```

**Benefits**: Monitor sprint progress from anywhere.

---

## Summary

The `/sprint-dashboard` command provides:
- **Visual progress tracking** with factory metaphor
- **Real-time updates** via auto-refresh
- **Interactive exploration** with filters and search
- **Team collaboration** tool for meetings
- **Historical archiving** for retrospectives

**Quick Reference**:
```bash
# Basic
/sprint-dashboard

# With options
/sprint-dashboard [date] --auto-refresh [seconds] --theme [theme] --open

# Common combinations
/sprint-dashboard --open                          # View immediately
/sprint-dashboard --auto-refresh 15               # Fast refresh
/sprint-dashboard --auto-refresh 0                # Static snapshot
/sprint-dashboard 2025-10-30 --open               # Specific sprint
```

**Pro Tips**:
- Keep dashboard open during work for motivation
- Use during standups for visual context
- Archive dashboards at sprint end
- Combine with /session-report for full metrics
- Update task status regularly for accuracy

---

For more information, see:
- Command documentation: `.claude/commands/sprint-dashboard.md`
- Test scaffold: `.claude/tests/test_sprint-dashboard_scaffold.sh`
- Sprint planning: `.claude/commands/plan-sprint.md`
