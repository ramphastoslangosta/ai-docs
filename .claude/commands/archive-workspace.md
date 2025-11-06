---
description: Archive a completed task workspace to preserve history and clean up active workspace directory
allowed-tools: Read, Write, Bash, Glob
argument-hint: TASK-ID - Task identifier to archive (e.g., TASK-20250929-012)
---

# Archive Workspace

Move a completed task workspace to the archive directory with metadata preservation, creating a timestamped snapshot of the completed work. Keeps the active workspace directory clean while maintaining historical records.

## Source Common Functions Library
```bash
# Source the common functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common-functions.sh"
```

## Pre-Archive Validation

### Verify Task ID
```bash
TASK_ID="${1}"

if [ -z "$TASK_ID" ]; then
    echo "❌ Error: Task ID required"
    echo "Usage: /archive-workspace TASK-ID"
    echo ""
    echo "Examples:"
    echo "  /archive-workspace TASK-20250929-012"
    echo "  /archive-workspace HOTFIX-20251006-001"
    exit 1
fi

WORKSPACE_DIR="workspace/$TASK_ID"

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "❌ Error: Workspace not found: $WORKSPACE_DIR"
    echo ""
    echo "Available workspaces:"
    ls workspace/ 2>/dev/null | grep -E "^[A-Z]+-[0-9]+-[0-9]+$"
    exit 1
fi

echo "📂 Found workspace: $WORKSPACE_DIR"
echo ""
```

### Check Workspace Completeness
```bash
# Verify workspace has required files
PLAN_FILE="$WORKSPACE_DIR/atomic-plan-$TASK_ID.md"
CHECKLIST_FILE="$WORKSPACE_DIR/checklist-$TASK_ID.md"
NOTES_FILE="$WORKSPACE_DIR/notes.md"
README_FILE="$WORKSPACE_DIR/README.md"

MISSING_FILES=()

if [ ! -f "$PLAN_FILE" ]; then
    MISSING_FILES+=("atomic-plan-$TASK_ID.md")
fi

if [ ! -f "$CHECKLIST_FILE" ]; then
    MISSING_FILES+=("checklist-$TASK_ID.md")
fi

if [ ! -f "$NOTES_FILE" ]; then
    MISSING_FILES+=("notes.md")
fi

if [ ! -f "$README_FILE" ]; then
    MISSING_FILES+=("README.md")
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo "⚠️  Warning: Workspace is missing required files:"
    for FILE in "${MISSING_FILES[@]}"; do
        echo "  - $FILE"
    done
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Archive cancelled"
        exit 1
    fi
fi
```

### Verify Completion Status
```bash
# Check if workspace is actually completed using library function
PROGRESS=$(get_workspace_progress "$TASK_ID" "$WORKSPACE_DIR")
PROGRESS_PCT=$(echo "$PROGRESS" | grep -o '[0-9]*%' | tr -d '%')

if [ -z "$PROGRESS_PCT" ]; then
    PROGRESS_PCT=0
    echo "⚠️  Warning: No checklist items found"
else
    echo "📊 Workspace Progress: $PROGRESS"
fi

if [ "$PROGRESS_PCT" -lt 100 ]; then
    echo ""
    echo "⚠️  Warning: Workspace is not 100% complete"
    echo "   Progress: $PROGRESS"
    echo ""
    read -p "Archive incomplete workspace? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Archive cancelled"
            exit 1
        fi
    else
        echo "✅ Workspace is complete"
    fi
else
    echo "⚠️  Warning: No checklist found"
fi

echo ""
```

### Check for Uncommitted Changes
```bash
# If in a git repository, check for uncommitted workspace files
if git rev-parse --git-dir > /dev/null 2>&1; then
    UNCOMMITTED=$(git status --short "$WORKSPACE_DIR" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo "⚠️  Warning: Workspace has uncommitted changes:"
        git status --short "$WORKSPACE_DIR"
        echo ""
        read -p "Commit before archiving? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            # Commit workspace before archiving using library function
            git_commit_with_message "docs: archive workspace $TASK_ID before archival" "$WORKSPACE_DIR"
        fi
        echo ""
    fi
fi
```

## Archive Execution

### Create Archive Directory
```bash
ARCHIVE_DIR="workspace/archive"

if [ ! -d "$ARCHIVE_DIR" ]; then
    echo "📁 Creating archive directory: $ARCHIVE_DIR"
    mkdir -p "$ARCHIVE_DIR"
fi
```

### Generate Archive Name
```bash
# Archive with timestamp: TASK-ID-completed-YYYYMMDD-HHMMSS
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE_NAME="${TASK_ID}-completed-${TIMESTAMP}"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

echo "📦 Archive destination: $ARCHIVE_PATH"
echo ""
```

### Create Archive Metadata
```bash
# Create archive metadata file before moving
METADATA_FILE="$WORKSPACE_DIR/ARCHIVE_METADATA.txt"

cat > "$METADATA_FILE" << EOF
Archive Metadata
================

Task ID: $TASK_ID
Archived On: $(date +"%Y-%m-%d %H:%M:%S")
Archived By: $(whoami)@$(hostname)
Archive Reason: Workspace completion

Workspace Statistics:
- Total Checklist Items: $TOTAL_ITEMS
- Completed Items: $COMPLETED_ITEMS
- Completion Percentage: $PROGRESS_PCT%
- Workspace Created: $(grep "Started:" "$README_FILE" 2>/dev/null | cut -d':' -f2- | xargs || echo "Unknown")
- Last Modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$NOTES_FILE" 2>/dev/null || echo "Unknown")

Files Archived:
$(ls -1 "$WORKSPACE_DIR" | sed 's/^/- /')

Archive Location: $ARCHIVE_PATH
Original Location: $WORKSPACE_DIR

Restoration Command:
  mv "$ARCHIVE_PATH" "$WORKSPACE_DIR"
EOF

echo "✅ Created archive metadata"
```

### Move Workspace to Archive
```bash
echo "🚚 Moving workspace to archive..."

if mv "$WORKSPACE_DIR" "$ARCHIVE_PATH"; then
    echo "✅ Workspace archived successfully"
else
    echo "❌ Error: Failed to move workspace"
    rm -f "$METADATA_FILE"  # Clean up metadata on failure
    exit 1
fi

echo ""
```

### Update tasks.csv (if exists)
```bash
# Update task status in tasks.csv if it exists
if [ -f "tasks.csv" ]; then
    if grep -q "^$TASK_ID," tasks.csv; then
        echo "📝 Updating tasks.csv status to 'archived'..."

        # Create backup
        cp tasks.csv tasks.csv.backup

        # Update status to archived using library function
        update_task_status "$TASK_ID" "archived" "tasks.csv"

        # Add archive note
        CURRENT_NOTES=$(grep "^$TASK_ID," tasks.csv | cut -d',' -f12)
        NEW_NOTES="Archived: $TIMESTAMP. $CURRENT_NOTES"
        sed -i '' "s/^$TASK_ID,\(.*\),[^,]*$/\1,$NEW_NOTES/" tasks.csv
    else
        echo "ℹ️  Task not found in tasks.csv (skipping update)"
    fi
else
    echo "ℹ️  No tasks.csv found (skipping update)"
fi

echo ""
```

### Create Archive Index
```bash
# Update or create archive index
ARCHIVE_INDEX="$ARCHIVE_DIR/ARCHIVE_INDEX.md"

if [ ! -f "$ARCHIVE_INDEX" ]; then
    cat > "$ARCHIVE_INDEX" << 'EOF'
# Workspace Archive Index

This directory contains archived task workspaces that have been completed or explicitly archived.

## Archived Workspaces

| Archive Name | Task ID | Archived On | Completion | Size | Notes |
|--------------|---------|-------------|------------|------|-------|
EOF
fi

# Add entry to index
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
printf "| %-40s | %-20s | %-19s | %6s | %6s | %s |\n" \
    "$ARCHIVE_NAME" \
    "$TASK_ID" \
    "$(date +"%Y-%m-%d %H:%M:%S")" \
    "$PROGRESS_PCT%" \
    "$ARCHIVE_SIZE" \
    "Completed workspace" >> "$ARCHIVE_INDEX"

echo "✅ Archive index updated"
echo ""
```

## Post-Archive Actions

### Generate Archive Summary
```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          ARCHIVE COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Archive Summary:"
echo "   Task ID: $TASK_ID"
echo "   Archive Name: $ARCHIVE_NAME"
echo "   Location: $ARCHIVE_PATH"
echo "   Size: $ARCHIVE_SIZE"
echo "   Completion: $PROGRESS_PCT%"
echo ""
echo "📁 Archive Contents:"
ls -lh "$ARCHIVE_PATH" | tail -n +2 | awk '{printf "   - %-40s %8s\n", $9, $5}'
echo ""
echo "✅ Actions Completed:"
echo "   ✓ Workspace moved to archive"
echo "   ✓ Archive metadata created"
echo "   ✓ Archive index updated"
if [ -f "tasks.csv" ] && grep -q "^$TASK_ID," tasks.csv; then
    echo "   ✓ tasks.csv status updated to 'archived'"
fi
echo ""
echo "🔗 Quick Actions:"
echo "   View archive: ls -la $ARCHIVE_PATH"
echo "   Read notes: cat $ARCHIVE_PATH/notes.md"
echo "   View metadata: cat $ARCHIVE_PATH/ARCHIVE_METADATA.txt"
echo "   Restore: mv $ARCHIVE_PATH $WORKSPACE_DIR"
echo ""
echo "📊 Archive Statistics:"
echo "   Total archived workspaces: $(ls -1d $ARCHIVE_DIR/*-completed-* 2>/dev/null | wc -l | tr -d ' ')"
echo "   Total archive size: $(du -sh $ARCHIVE_DIR 2>/dev/null | cut -f1)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Verify Archive Integrity
```bash
# Verify archive was created correctly
echo "🔍 Verifying archive integrity..."

VERIFICATION_FAILED=false

# Check archive exists
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Error: Archive directory not found"
    VERIFICATION_FAILED=true
fi

# Check required files exist in archive
for FILE in "$ARCHIVE_PATH/ARCHIVE_METADATA.txt"; do
    if [ ! -f "$FILE" ]; then
        echo "❌ Error: Missing file in archive: $(basename $FILE)"
        VERIFICATION_FAILED=true
    fi
done

# Check original workspace no longer exists
if [ -d "$WORKSPACE_DIR" ]; then
    echo "❌ Error: Original workspace still exists at $WORKSPACE_DIR"
    VERIFICATION_FAILED=true
fi

if [ "$VERIFICATION_FAILED" = false ]; then
    echo "✅ Archive integrity verified"
else
    echo ""
    echo "⚠️  Archive verification failed"
    echo "   Manual inspection required: $ARCHIVE_PATH"
fi

echo ""
```

## Expected Outcomes

After executing this command, you should have:

### Immediate Results
1. **Workspace moved** from `workspace/TASK-ID/` to `workspace/archive/TASK-ID-completed-YYYYMMDD-HHMMSS/`
2. **Archive metadata** created in `ARCHIVE_METADATA.txt`
3. **Archive index** updated with new entry
4. **tasks.csv updated** with "archived" status (if file exists)
5. **Verification summary** confirming successful archive

### Archive Structure
```
workspace/
├── archive/
│   ├── ARCHIVE_INDEX.md
│   ├── TASK-20250929-012-completed-20251008-143022/
│   │   ├── ARCHIVE_METADATA.txt (NEW)
│   │   ├── atomic-plan-TASK-20250929-012.md
│   │   ├── checklist-TASK-20250929-012.md
│   │   ├── notes.md
│   │   ├── README.md
│   │   └── success-criteria.md
│   └── HOTFIX-20251006-001-completed-20251008-143045/
│       └── ...
└── [active workspaces only]
```

### Archive Metadata Contents
```
Archive Metadata
================

Task ID: TASK-20250929-012
Archived On: 2025-10-08 14:30:22
Archived By: developer@hostname
Archive Reason: Workspace completion

Workspace Statistics:
- Total Checklist Items: 64
- Completed Items: 64
- Completion Percentage: 100%
- Workspace Created: 2025-09-29 10:15:00
- Last Modified: 2025-10-01 16:45:30

Files Archived:
- ARCHIVE_METADATA.txt
- atomic-plan-TASK-20250929-012.md
- checklist-TASK-20250929-012.md
- completion-report.md
- notes.md
- README.md
- success-criteria.md

Archive Location: workspace/archive/TASK-20250929-012-completed-20251008-143022
Original Location: workspace/TASK-20250929-012

Restoration Command:
  mv workspace/archive/TASK-20250929-012-completed-20251008-143022 workspace/TASK-20250929-012
```

## Use Cases

### After Task Completion
```bash
# Complete the task
/execute-task TASK-20250929-012

# Verify completion
/list-workspaces completed

# Archive it
/archive-workspace TASK-20250929-012
```

### Before Sprint End
```bash
# List all completed workspaces
/list-workspaces completed

# Archive each one
/archive-workspace DEVOPS-20251001-001
/archive-workspace HOTFIX-20251006-001
```

### Periodic Cleanup
```bash
# Monthly: Archive all completed workspaces
for TASK in $(ls workspace/ | grep -v archive); do
    if /list-workspaces $TASK | grep -q "Complete"; then
        /archive-workspace $TASK
    fi
done
```

## Restoration

### Restore from Archive
```bash
# Find archived workspace
ls -la workspace/archive/ | grep TASK-20250929-012

# Restore to active
mv workspace/archive/TASK-20250929-012-completed-20251008-143022 workspace/TASK-20250929-012

# Update tasks.csv if needed
sed -i '' "s/^TASK-20250929-012,\([^,]*\),archived,/TASK-20250929-012,\1,in-progress,/" tasks.csv
```

## Troubleshooting

### Archive Already Exists
```bash
# Error: workspace/archive/TASK-ID-completed-* already exists
# Solution: Use a different timestamp or remove old archive
ls workspace/archive/ | grep TASK-ID
mv workspace/archive/TASK-ID-completed-OLD workspace/archive/TASK-ID-completed-OLD.bak
```

### Permission Denied
```bash
# Error: Permission denied when moving workspace
# Solution: Check file permissions
ls -la workspace/TASK-ID
chmod -R u+w workspace/TASK-ID
```

### Incomplete Workspace
```bash
# Error: Missing required files
# Solution: Archive anyway with --force flag (implement if needed)
# Or manually create missing files
touch workspace/TASK-ID/notes.md
```

### Git Conflicts
```bash
# Error: Uncommitted changes
# Solution: Commit before archiving
git add workspace/TASK-ID
git commit -m "docs: finalize workspace TASK-ID"
/archive-workspace TASK-ID
```

## Best Practices

1. **Archive completed workspaces promptly** - Keep active directory clean
2. **Verify completion before archiving** - Check 100% progress
3. **Commit changes before archiving** - Preserve git history
4. **Review archive periodically** - Clean up very old archives (>1 year)
5. **Backup archive directory** - Include in backup strategy
6. **Document restoration process** - Update team docs

## Integration with Other Commands

### Workflow Chain
```bash
# 1. List completed workspaces
/list-workspaces completed

# 2. Archive them
/archive-workspace TASK-ID

# 3. Verify archive
ls -la workspace/archive/
cat workspace/archive/ARCHIVE_INDEX.md
```

### With Cleanup
```bash
# Archive completed first
/list-workspaces completed | grep TASK | while read TASK _; do
    /archive-workspace $TASK
done

# Then cleanup abandoned
/cleanup-workspaces
```

## Archive Statistics

View archive statistics:
```bash
# Count archived workspaces
ls -1d workspace/archive/*-completed-* | wc -l

# Total archive size
du -sh workspace/archive

# List by date
ls -lt workspace/archive/

# Find specific archive
grep "TASK-20250929-012" workspace/archive/ARCHIVE_INDEX.md
```
