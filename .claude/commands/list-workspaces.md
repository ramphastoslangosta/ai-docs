---
description: List all task workspaces with their status and progress metrics
allowed-tools: Read, Bash, Glob, Grep
argument-hint: [status] - Filter by status (active, completed, abandoned, stale, all). Default: all
---

# List Workspaces

Display all task workspaces with their current status, progress metrics, and metadata. Helps identify active work, completed tasks, and abandoned workspaces that need cleanup.

## Discovery

### Source Common Functions Library
```bash
# Source the common functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common-functions.sh"
```

### Find All Workspaces
```bash
# Find all workspace directories
WORKSPACES=$(find workspace -maxdepth 1 -type d -name "*-*" 2>/dev/null | sort)

if [ -z "$WORKSPACES" ]; then
    echo "📭 No workspaces found"
    exit 0
fi

WORKSPACE_COUNT=$(echo "$WORKSPACES" | wc -l | tr -d ' ')
echo "📂 Found $WORKSPACE_COUNT workspace(s)"
echo ""
```

### Extract Workspace Metadata
For each workspace, extract:
- Task ID (from directory name)
- Creation date (from atomic-plan file timestamp)
- Last modified (from notes.md timestamp)
- Progress (from checklist completion count)
- Status (derived from progress and age)

```bash
# Analyze each workspace
for WORKSPACE_DIR in $WORKSPACES; do
    TASK_ID=$(basename "$WORKSPACE_DIR")

    # Check if workspace has required files
    PLAN_FILE="$WORKSPACE_DIR/atomic-plan-$TASK_ID.md"
    CHECKLIST_FILE="$WORKSPACE_DIR/checklist-$TASK_ID.md"
    NOTES_FILE="$WORKSPACE_DIR/notes.md"
    README_FILE="$WORKSPACE_DIR/README.md"

    # Extract metadata
    if [ -f "$README_FILE" ]; then
        CREATED=$(grep "Started:" "$README_FILE" 2>/dev/null | cut -d':' -f2- | xargs)
    else
        CREATED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$WORKSPACE_DIR" 2>/dev/null || echo "Unknown")
    fi

    if [ -f "$NOTES_FILE" ]; then
        LAST_MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$NOTES_FILE" 2>/dev/null || echo "Unknown")
    else
        LAST_MODIFIED="Never"
    fi

    # Calculate progress using library function
    PROGRESS=$(get_workspace_progress "$TASK_ID" "$WORKSPACE_DIR")

    # Extract percentage for numeric comparisons
    PROGRESS_PCT=$(echo "$PROGRESS" | grep -o '[0-9]*%' | tr -d '%')
    if [ -z "$PROGRESS_PCT" ]; then
        PROGRESS_PCT=0
    fi

    # Store metadata (will be used for classification)
done
```

## Status Classification

Classify workspaces based on progress and activity:

### Active Workspace
- Progress: 1-99%
- Last modified: < 7 days ago
- Has notes.md with recent entries

### Completed Workspace
- Progress: 100% (all checklist items marked [x])
- Has completion-report.md or success-criteria.md with verification

### Stale Workspace
- Progress: 1-99%
- Last modified: 7-30 days ago
- No recent activity but not abandoned

### Abandoned Workspace
- Progress: 0-99%
- Last modified: > 30 days ago
- No completion markers

### Empty Workspace
- Missing required files (atomic-plan, checklist, or notes)
- Progress: 0%

```bash
classify_workspace() {
    local TASK_ID=$1
    local PROGRESS_PCT=$2
    local LAST_MODIFIED_DAYS=$3
    local HAS_COMPLETION=$4

    # Check for completion markers
    if [ "$PROGRESS_PCT" -eq 100 ] || [ "$HAS_COMPLETION" = "true" ]; then
        echo "completed"
    elif [ "$PROGRESS_PCT" -eq 0 ] && [ "$LAST_MODIFIED_DAYS" -gt 30 ]; then
        echo "abandoned"
    elif [ "$PROGRESS_PCT" -gt 0 ] && [ "$LAST_MODIFIED_DAYS" -gt 30 ]; then
        echo "abandoned"
    elif [ "$PROGRESS_PCT" -gt 0 ] && [ "$LAST_MODIFIED_DAYS" -gt 7 ]; then
        echo "stale"
    elif [ "$PROGRESS_PCT" -gt 0 ] && [ "$PROGRESS_PCT" -lt 100 ]; then
        echo "active"
    else
        echo "empty"
    fi
}

# Calculate days since last modification
days_since_modified() {
    local FILE=$1
    if [ -f "$FILE" ]; then
        local MODIFIED_TIMESTAMP=$(stat -f %m "$FILE" 2>/dev/null || echo 0)
        local CURRENT_TIMESTAMP=$(date +%s)
        local DAYS=$(( (CURRENT_TIMESTAMP - MODIFIED_TIMESTAMP) / 86400 ))
        echo "$DAYS"
    else
        echo "999"  # Very old if file doesn't exist
    fi
}
```

## Display Formatting

### Summary Header
```
📂 Workspace Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Workspaces: {COUNT}
  ✅ Completed:   {COMPLETED_COUNT}
  🚀 Active:      {ACTIVE_COUNT}
  ⏸️  Stale:       {STALE_COUNT}
  ⚠️  Abandoned:   {ABANDONED_COUNT}
  📭 Empty:       {EMPTY_COUNT}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Workspace Details Table
```
Task ID              Status      Progress  Created      Last Modified  Age
────────────────────────────────────────────────────────────────────────────
TASK-20250929-012    ✅ Complete 64/64     2025-09-29   2025-10-01     9d
HOTFIX-20251001-002  🚀 Active   12/23     2025-10-01   2025-10-08     7d
ARCH-20251003-001    ⏸️  Stale    8/45      2025-10-03   2025-10-05     3d
PROCESS-20251001-001 ⚠️  Abandon  0/32      2025-10-01   2025-10-01     7d
DEVOPS-20251001-001  📭 Empty    0/0       2025-10-01   Never          7d
────────────────────────────────────────────────────────────────────────────
```

### Filtering

When status filter is provided, show only matching workspaces:

```bash
# Example: /list-workspaces active
STATUS_FILTER="${1:-all}"

if [ "$STATUS_FILTER" != "all" ]; then
    echo "🔍 Filtering by status: $STATUS_FILTER"
    echo ""
fi

# Filter and display
for WORKSPACE in $WORKSPACES; do
    WORKSPACE_STATUS=$(classify_workspace ...)

    if [ "$STATUS_FILTER" = "all" ] || [ "$STATUS_FILTER" = "$WORKSPACE_STATUS" ]; then
        # Display this workspace
        display_workspace_row "$WORKSPACE"
    fi
done
```

## Output Examples

### Example 1: All Workspaces
```bash
/list-workspaces
```

Output:
```
📂 Workspace Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Workspaces: 8
  ✅ Completed:   2
  🚀 Active:      3
  ⏸️  Stale:       1
  ⚠️  Abandoned:   2
  📭 Empty:       0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Task ID                Status        Progress  Created      Last Modified  Age
──────────────────────────────────────────────────────────────────────────────
ARCH-20251003-001      🚀 Active     35/45     2025-10-03   2025-10-08     5d
ARCH-20251007-001      🚀 Active     8/12      2025-10-07   2025-10-08     1d
DEVOPS-20251001-001    ✅ Complete   64/64     2025-10-01   2025-10-03     7d
HOTFIX-20251001-002    🚀 Active     12/23     2025-10-01   2025-10-08     7d
HOTFIX-20251006-001    ✅ Complete   45/45     2025-10-06   2025-10-07     2d
MTENANT-20251006-001   ⏸️  Stale      18/56     2025-10-06   2025-10-07     2d
PROCESS-20251001-001   ⚠️  Abandon    0/32      2025-10-01   2025-10-01     7d
TASK-20250929-012      ⚠️  Abandon    5/18      2025-09-29   2025-09-30     9d
──────────────────────────────────────────────────────────────────────────────

💡 Tips:
  • Archive completed: /archive-workspace DEVOPS-20251001-001
  • Cleanup abandoned: /cleanup-workspaces
  • Filter by status: /list-workspaces active
```

### Example 2: Active Workspaces Only
```bash
/list-workspaces active
```

Output:
```
🔍 Filtering by status: active

📂 Active Workspaces (3)

Task ID                Progress  Created      Last Modified  Age    Next Step
────────────────────────────────────────────────────────────────────────────────────
ARCH-20251003-001      35/45     2025-10-03   2025-10-08     5d     Step 36: Implement caching layer
ARCH-20251007-001      8/12      2025-10-07   2025-10-08     1d     Step 9: Add Docker volume mounts
HOTFIX-20251001-002    12/23     2025-10-01   2025-10-08     7d     Step 13: Create integration tests
────────────────────────────────────────────────────────────────────────────────────

💡 Continue work: /execute-task ARCH-20251003-001
```

### Example 3: Completed Workspaces
```bash
/list-workspaces completed
```

Output:
```
🔍 Filtering by status: completed

✅ Completed Workspaces (2)

Task ID                Progress  Completed On  Duration  Outcome
───────────────────────────────────────────────────────────────────
DEVOPS-20251001-001    64/64     2025-10-03    2 days    All deployment tests passed
HOTFIX-20251006-001    45/45     2025-10-07    1 day     Hotfix deployed successfully
───────────────────────────────────────────────────────────────────

💡 Archive these: /archive-workspace DEVOPS-20251001-001
```

### Example 4: Abandoned Workspaces
```bash
/list-workspaces abandoned
```

Output:
```
🔍 Filtering by status: abandoned

⚠️  Abandoned Workspaces (2)

Task ID                Progress  Last Modified  Age    Recommendation
─────────────────────────────────────────────────────────────────────────────
PROCESS-20251001-001   0/32      2025-10-01     7d     Delete (no progress)
TASK-20250929-012      5/18      2025-09-30     9d     Review or archive
─────────────────────────────────────────────────────────────────────────────

💡 Clean up all: /cleanup-workspaces
💡 Review specific: cat workspace/TASK-20250929-012/notes.md
```

## Expected Outcomes

After executing this command, you should receive:

### Immediate Response
1. **Summary statistics** - Count of workspaces by status
2. **Workspace table** - Detailed view of each workspace
3. **Action recommendations** - Suggested next steps based on status

### Use Cases
- **Daily standup**: Quickly see what tasks are active
- **Sprint planning**: Identify stale or abandoned work
- **Cleanup preparation**: Find workspaces ready for archival
- **Team coordination**: Share workspace status with team

### Follow-up Actions
- Archive completed workspaces: `/archive-workspace TASK-ID`
- Cleanup abandoned workspaces: `/cleanup-workspaces`
- Resume active work: `/execute-task TASK-ID`
- Review stale workspace: `cat workspace/TASK-ID/notes.md`

## Troubleshooting

### No Workspaces Found
```bash
# Solution: Check if workspace directory exists
ls -la workspace/

# If missing, create it
mkdir -p workspace
```

### Incorrect Progress Calculation
```bash
# Solution: Verify checklist format
cat workspace/TASK-ID/checklist-TASK-ID.md

# Ensure proper checkbox format: - [ ] or - [x]
```

### Wrong Status Classification
```bash
# Solution: Manually check last modification
stat -f "%Sm" workspace/TASK-ID/notes.md

# Or check completion markers
ls workspace/TASK-ID/*completion* workspace/TASK-ID/*success*
```

### Missing Metadata
```bash
# Solution: Workspace might be incomplete
# List all files in workspace
ls -la workspace/TASK-ID/

# Required files:
# - atomic-plan-TASK-ID.md
# - checklist-TASK-ID.md
# - notes.md
# - README.md
```

## Advanced Usage

### Sort by Progress
```bash
/list-workspaces all | sort -k3 -t'/' -n
```

### Export to CSV
```bash
/list-workspaces all > workspace-report.csv
```

### Find Workspaces by Age
```bash
# Workspaces older than 30 days
/list-workspaces all | awk '$NF ~ /[0-9]+d/ && $NF+0 > 30'
```

### Group by Type
```bash
# Analyze workspace types
ls workspace/ | sed 's/-.*//' | sort | uniq -c
```

## Integration with Other Commands

### Before Archive
```bash
# List completed workspaces
/list-workspaces completed

# Archive each one
/archive-workspace TASK-ID
```

### Before Cleanup
```bash
# Review abandoned workspaces
/list-workspaces abandoned

# Clean up all at once
/cleanup-workspaces
```

### Daily Workflow
```bash
# Morning: Check active work
/list-workspaces active

# Evening: Update progress
/execute-task TASK-ID

# Weekly: Clean up
/list-workspaces abandoned
/cleanup-workspaces
```
