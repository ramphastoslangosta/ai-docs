# Usage Examples: /session-report

Comprehensive examples for using the `/session-report` command to generate HTML dashboards with infographic summaries.

## Basic Usage

### Example 1: Simple Session Report

**Scenario**: Generate a basic session report at the end of your work day.

```bash
/session-report
```

**Output**:
```
📊 Generating session report...
   Output: docs/session-reports/session-20251029-173045.html

✅ Git repository detected
✅ Workspace directory found
✅ Task tracker found

🔍 Collecting session data...
  Session duration: 3h 45m
  Tasks: 4/12 completed (33%)
  Active workspaces: 2
  Checklist items: 18/35 completed
  Files modified: 23

🎨 Generating HTML dashboard...
✅ HTML dashboard generated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          SESSION REPORT GENERATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary Statistics:
   Session Duration: 3h 45m
   Tasks Completed: 4/12 (33%)
   Checklist Items: 18/35
   Active Workspaces: 2
   Files Modified: 23

📁 Generated Files:
   HTML Dashboard: docs/session-reports/session-20251029-173045.html

🌐 View Dashboard:
   open docs/session-reports/session-20251029-173045.html
```

**What you get**:
- Interactive HTML dashboard
- Session duration: 3h 45m
- Task completion: 33% (4/12 tasks)
- File activity heatmap showing 23 modified files
- Checklist progress visualization

---

## Advanced Usage

### Example 2: Session Report with Git Metrics

**Scenario**: You've made several commits and want to see git activity alongside session metrics.

```bash
/session-report --include-git
```

**Additional Output**:
```
  Git commits today: 8
  Files modified: 15 (staged: 5)
  Lines changed: +347 -128
```

**Dashboard additions**:
- Current git branch: `feature/dashboard-improvements`
- Commits made today: 8
- Files changed: 15 (5 staged)
- Lines added: +347
- Lines removed: -128

**Use case**: Perfect for daily standups or progress reports where git activity is relevant.

---

### Example 3: Custom Output Location

**Scenario**: Organize reports by sprint or date in a custom directory structure.

```bash
# Create sprint-specific directory
mkdir -p docs/sprints/sprint-16

# Generate report in custom location
/session-report docs/sprints/sprint-16
```

**Result**:
- Report saved to: `docs/sprints/sprint-16/session-20251029-173045.html`
- Organized by sprint for historical tracking
- Easy to find and compare across sprints

**Workflow integration**:
```bash
# At sprint end
SPRINT_NUM=16
/session-report docs/sprints/sprint-${SPRINT_NUM} --include-git

# Review sprint metrics
open docs/sprints/sprint-${SPRINT_NUM}/session-*.html
```

---

### Example 4: JSON Data Export

**Scenario**: You need machine-readable session data for automation or further processing.

```bash
/session-report --format json
```

**Output files**:
1. `docs/session-reports/session-20251029-173045.html` (visual dashboard)
2. `docs/session-reports/session-20251029-173045.json` (raw data)

**JSON structure**:
```json
{
  "session": {
    "timestamp": "20251029-173045",
    "start": "2025-10-29 14:00:00",
    "end": "2025-10-29 17:30:45",
    "duration_minutes": 225,
    "project": "ai-docs"
  },
  "tasks": {
    "total": 12,
    "completed": 4,
    "in_progress": 2,
    "pending": 6,
    "completion_rate": 33
  },
  "workspaces": {
    "active": 2,
    "total_checklist_items": 35,
    "completed_checklist_items": 18
  },
  "files": {
    "total_modified": 23,
    "by_type": {
      "python": 5,
      "javascript": 3,
      "markdown": 12,
      "shell": 2,
      "other": 1
    }
  }
}
```

**Use cases for JSON**:
```bash
# Parse JSON for specific metrics
jq '.tasks.completion_rate' session-20251029-173045.json
# Output: 33

# Extract file activity
jq '.files.by_type' session-20251029-173045.json

# Automate tracking
cat session-*.json | jq '.session.duration_minutes' | \
  awk '{sum+=$1} END {print "Total time: " sum/60 " hours"}'
```

---

### Example 5: Complete Report (All Options)

**Scenario**: Generate a comprehensive end-of-sprint report with all features enabled.

```bash
/session-report docs/sprint-reviews/sprint-16-final --include-git --format json
```

**What you get**:
1. **HTML Dashboard** with:
   - Full session timeline
   - Task completion metrics
   - Git activity analysis (commits, files, lines)
   - File modification heatmap
   - Checklist progress
   - Interactive visualizations

2. **JSON Data** with:
   - Complete session metadata
   - All metrics in structured format
   - Ready for programmatic processing

**Output**:
```
📊 Summary Statistics:
   Session Duration: 80h 15m (across sprint)
   Tasks Completed: 24/28 (86%)
   Checklist Items: 145/152
   Active Workspaces: 1
   Files Modified: 127
   Git Commits: 42
   Lines Changed: +2,847 -1,234

📁 Generated Files:
   HTML Dashboard: docs/sprint-reviews/sprint-16-final/session-20251029-173045.html
   JSON Data: docs/sprint-reviews/sprint-16-final/session-20251029-173045.json
```

**Presentation workflow**:
```bash
# Generate comprehensive report
/session-report docs/sprint-reviews/sprint-16-final --include-git

# Open for team review
open docs/sprint-reviews/sprint-16-final/session-*.html

# Share with stakeholders
# - Email HTML file
# - Present in sprint review meeting
# - Archive for historical reference
```

---

## Workflow Integration

### Example 6: Daily Standup Preparation

**Scenario**: Generate a daily report for standup meetings.

```bash
# Morning routine - generate yesterday's report
YESTERDAY=$(date -v-1d +%Y-%m-%d)
mkdir -p docs/standups
/session-report docs/standups/$YESTERDAY --include-git

# Review before standup
open docs/standups/$YESTERDAY/session-*.html
```

**Standup talking points from dashboard**:
- "Completed 3 of 5 planned tasks yesterday"
- "Made 6 commits, added 245 lines of code"
- "Working in 2 active workspaces"
- "18 of 24 checklist items done"

---

### Example 7: After Task Completion

**Scenario**: Document accomplishments after finishing a major task.

```bash
# Complete task workflow
/execute-task TASK-20251029-001
# ... work on task ...
/archive-workspace TASK-20251029-001

# Generate accomplishment report
/session-report docs/task-completions/TASK-20251029-001 --include-git

# Review what was accomplished
open docs/task-completions/TASK-20251029-001/session-*.html
```

**Dashboard shows**:
- Time spent: 2h 30m
- Files modified: 8 files
- Tests written: 3 new test files
- Commits: 5 atomic commits
- Lines changed: +289 -45

---

### Example 8: Weekly Progress Tracking

**Scenario**: Track weekly velocity and productivity trends.

```bash
# Friday end-of-week routine
WEEK=$(date +%Y-W%U)
mkdir -p docs/weekly-reports

# Generate weekly summary
/session-report docs/weekly-reports/$WEEK --include-git --format json

# View dashboard
open docs/weekly-reports/$WEEK/session-*.html

# Extract weekly metrics for tracking
jq '{
  week: "'$WEEK'",
  tasks_completed: .tasks.completed,
  hours_worked: (.session.duration_minutes / 60),
  commits: .git.commits_today,
  velocity: (.tasks.completed / (.session.duration_minutes / 480))
}' docs/weekly-reports/$WEEK/session-*.json >> docs/velocity-tracking.jsonl
```

**Trend analysis**:
```bash
# Plot weekly velocity
cat docs/velocity-tracking.jsonl | jq -r '[.week, .velocity] | @csv'

# Compare weeks
jq -s 'map({week, tasks: .tasks_completed}) | group_by(.week)' \
  docs/weekly-reports/*/session-*.json
```

---

### Example 9: Sprint Retrospective

**Scenario**: Generate comprehensive sprint retrospective data.

```bash
# At sprint end (2-week sprint)
SPRINT=16
SPRINT_START="2025-10-15"
SPRINT_END="2025-10-29"

# Generate final sprint report
/session-report docs/sprints/sprint-$SPRINT/retrospective --include-git

# Open for team review
open docs/sprints/sprint-$SPRINT/retrospective/session-*.html
```

**Retrospective discussion points**:
- **Velocity**: Completed 24/28 tasks (86%)
- **Quality**: 42 commits with comprehensive test coverage
- **Efficiency**: Average 3.2h per task
- **Code health**: +2,847 lines added (new features), -1,234 removed (refactoring)
- **Blockers**: 3 tasks pending (carried to next sprint)

---

### Example 10: CI/CD Integration

**Scenario**: Automatically generate build reports in CI pipeline.

```bash
# In CI/CD pipeline script
BUILD_ID=${CI_BUILD_ID:-local}
BUILD_BRANCH=${CI_BRANCH:-main}

# Generate build session report
/session-report reports/builds/${BUILD_BRANCH}/${BUILD_ID} --format json

# Extract metrics for monitoring
COMPLETION_RATE=$(jq -r '.tasks.completion_rate' \
  reports/builds/${BUILD_BRANCH}/${BUILD_ID}/session-*.json)

# Post to monitoring dashboard
curl -X POST https://metrics.company.com/api/builds \
  -H "Content-Type: application/json" \
  -d @reports/builds/${BUILD_BRANCH}/${BUILD_ID}/session-*.json

# Archive report
aws s3 cp reports/builds/${BUILD_BRANCH}/${BUILD_ID}/ \
  s3://build-reports/${BUILD_BRANCH}/${BUILD_ID}/ --recursive
```

---

## Edge Cases & Special Scenarios

### Example 11: Empty Session (No Activity)

**Scenario**: Generate report when no tasks were completed.

```bash
# Start new project, no activity yet
/session-report
```

**Output**:
```
📊 Summary Statistics:
   Session Duration: 0h 15m
   Tasks Completed: 0/0 (0%)
   Checklist Items: 0/0
   Active Workspaces: 0
   Files Modified: 0
```

**Dashboard shows**:
- All metrics at zero
- Still useful to track "setup time"
- Provides baseline for future comparisons

---

### Example 12: Multi-Project Tracking

**Scenario**: Track sessions across multiple projects.

```bash
# Project A session
cd ~/projects/project-a
/session-report ~/session-reports/project-a --include-git

# Project B session
cd ~/projects/project-b
/session-report ~/session-reports/project-b --include-git

# Compare projects
ls -la ~/session-reports/*/session-*.html
```

**Comparison analysis**:
```bash
# Extract metrics from both
PROJECT_A_TASKS=$(jq -r '.tasks.completed' \
  ~/session-reports/project-a/session-*.json)

PROJECT_B_TASKS=$(jq -r '.tasks.completed' \
  ~/session-reports/project-b/session-*.json)

echo "Project A: $PROJECT_A_TASKS tasks"
echo "Project B: $PROJECT_B_TASKS tasks"
```

---

### Example 13: Long-Running Session

**Scenario**: Multi-day work session (e.g., hackathon, sprint).

```bash
# Day 1
/session-report docs/hackathon-2025/day1 --include-git

# Day 2
/session-report docs/hackathon-2025/day2 --include-git

# Day 3 (final)
/session-report docs/hackathon-2025/day3-final --include-git --format json

# Aggregate results
jq -s '{
  total_tasks: map(.tasks.completed) | add,
  total_commits: map(.git.commits_today) | add,
  total_lines_added: map(.git.lines_added) | add
}' docs/hackathon-2025/*/session-*.json
```

---

## Automation Examples

### Example 14: Automated Daily Reports

**Scenario**: Generate reports automatically every evening.

**Cron job** (add to crontab):
```bash
# Generate daily report at 6 PM
0 18 * * * cd /path/to/project && /session-report docs/daily/$(date +\%Y-\%m-\%d) --include-git
```

**Alternative: Git hook** (.git/hooks/post-commit):
```bash
#!/bin/bash
# Auto-generate report after each commit
/session-report /tmp/latest-commit --include-git
```

---

### Example 15: Slack Integration

**Scenario**: Post session summary to Slack channel.

```bash
# Generate report with JSON
/session-report /tmp/session --include-git --format json

# Extract metrics
TASKS=$(jq -r '.tasks.completed' /tmp/session/session-*.json)
COMMITS=$(jq -r '.git.commits_today' /tmp/session/session-*.json)
DURATION=$(jq -r '.session.duration_minutes' /tmp/session/session-*.json)

# Post to Slack
curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
  -H 'Content-Type: application/json' \
  -d "{
    \"text\": \"📊 Daily Session Report\",
    \"blocks\": [{
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"*Session Summary*\n• Tasks: $TASKS completed\n• Commits: $COMMITS\n• Duration: $((DURATION/60))h $((DURATION%60))m\"
      }
    }]
  }"
```

---

## Best Practices

### Organizing Reports

```bash
# By date
/session-report docs/reports/$(date +%Y/%m/%d)

# By sprint
/session-report docs/sprints/sprint-$SPRINT_NUMBER

# By feature
/session-report docs/features/user-authentication

# By developer (team setting)
/session-report docs/team/${USER}/$(date +%Y-%m-%d)
```

### Archiving Old Reports

```bash
# Archive reports older than 30 days
find docs/session-reports -name "session-*.html" -mtime +30 \
  -exec mv {} docs/archives/ \;

# Compress old reports
tar -czf session-reports-$(date +%Y-%m).tar.gz docs/archives/session-*.html
```

### Sharing Reports

```bash
# Email as attachment (macOS)
/session-report /tmp/report --include-git
echo "Session report attached" | mail -s "Daily Progress" \
  -a /tmp/report/session-*.html team@company.com

# Upload to cloud storage
/session-report /tmp/report
aws s3 cp /tmp/report/session-*.html s3://reports/$(date +%Y-%m-%d)/

# Share via HTTP
/session-report /tmp/report
python3 -m http.server 8080 -d /tmp/report
# Visit: http://localhost:8080/session-*.html
```

---

## Troubleshooting Examples

### Missing Data Sources

```bash
# Initialize if needed
git init
touch .claude/tasks.csv
mkdir -p .claude/workspace

# Then generate report
/session-report
```

### Custom Metrics

```bash
# Add custom metrics by editing HTML post-generation
/session-report /tmp/report

# Add custom section to HTML
echo "<div class='custom-metric'>Custom: Value</div>" >> /tmp/report/session-*.html
```

---

## Summary

The `/session-report` command is versatile and can be used for:
- ✅ Daily standup preparation
- ✅ Sprint retrospectives
- ✅ Progress tracking
- ✅ Team communication
- ✅ Productivity analysis
- ✅ Historical archiving
- ✅ CI/CD metrics
- ✅ Automated reporting

Choose the combination of flags (`--include-git`, `--format json`) and output paths that best fit your workflow!
