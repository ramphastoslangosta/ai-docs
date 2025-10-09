# Workspace Management Commands

Three slash commands for managing task workspaces throughout their lifecycle.

## Commands Overview

### `/list-workspaces [status]`
**Purpose**: Display all task workspaces with status, progress metrics, and activity analysis.

**Usage**:
```bash
/list-workspaces           # List all workspaces
/list-workspaces active    # Show only active work
/list-workspaces completed # Find workspaces ready for archival
/list-workspaces stale     # Workspaces with no recent activity
/list-workspaces abandoned # Candidates for cleanup
```

**Status Classification**:
- **Active** (🚀): 1-99% progress, modified within 7 days
- **Completed** (✅): 100% checklist completion
- **Stale** (⏸️): Has progress but inactive 7-30 days
- **Abandoned** (⚠️): Inactive >30 days or 0% progress >7 days
- **Empty** (📭): No checklist items, minimal activity

**Output Example**:
```
📂 Workspace Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Workspaces: 8
  ✅ Completed:   2
  🚀 Active:      3
  ⏸️  Stale:       1
  ⚠️  Abandoned:   2

Task ID              Status      Progress  Last Modified  Age
────────────────────────────────────────────────────────────
ARCH-20251003-001    🚀 Active   35/45     2025-10-08     5d
DEVOPS-20251001-001  ✅ Complete 64/64     2025-10-03     7d
...
```

---

### `/archive-workspace TASK-ID`
**Purpose**: Archive completed workspaces with metadata preservation and full restoration capability.

**Usage**:
```bash
/archive-workspace TASK-20250929-012
```

**What it Does**:
1. ✅ Validates workspace exists and checks completion (prompts if <100%)
2. ✅ Commits any uncommitted git changes
3. ✅ Creates archive metadata file with statistics
4. ✅ Moves workspace to `workspace/archive/TASK-ID-completed-{timestamp}/`
5. ✅ Updates `tasks.csv` status to "archived"
6. ✅ Updates archive index for tracking

**Archive Structure**:
```
workspace/archive/
├── ARCHIVE_INDEX.md
└── TASK-20250929-012-completed-20251008-143022/
    ├── ARCHIVE_METADATA.txt  ← Statistics and restoration commands
    ├── atomic-plan-TASK-20250929-012.md
    ├── checklist-TASK-20250929-012.md
    ├── notes.md
    └── README.md
```

**Restoration**:
```bash
# Restore archived workspace
mv workspace/archive/TASK-ID-completed-{timestamp} workspace/TASK-ID

# Update tasks.csv if needed
sed -i '' "s/^TASK-ID,\([^,]*\),archived,/TASK-ID,\1,in-progress,/" tasks.csv
```

---

### `/cleanup-workspaces [--dry-run] [--days N] [--force]`
**Purpose**: Automatically remove abandoned workspaces with safety mechanisms and full backup.

**Usage**:
```bash
/cleanup-workspaces --dry-run              # Preview deletions (recommended first)
/cleanup-workspaces                        # Execute with confirmation prompt
/cleanup-workspaces --days 14              # More aggressive (14 day threshold)
/cleanup-workspaces --force                # Skip confirmation (for automation)
/cleanup-workspaces --progress-threshold 5 # Only cleanup <5% progress
```

**Cleanup Criteria**:
| Condition | Age | Progress | Action |
|-----------|-----|----------|--------|
| Abandoned | >30 days | <10% | ✅ Delete |
| Empty | >7 days | 0% | ✅ Delete |
| Completed | Any | 100% | ⚠️ Archive instead (never deleted) |
| Stale with progress | >30 days | ≥10% | ⚠️ Manual review required |
| Active | <30 days | Any | ✅ Keep |

**Safety Features**:
- ✅ **Dry-run mode** - Preview before execution
- ✅ **Confirmation prompt** - Explicit "yes" required (unless --force)
- ✅ **Automatic backup** - Full backup to `workspace/.cleanup-backup/cleanup-{timestamp}/`
- ✅ **Deletion manifest** - Complete log with restoration commands
- ✅ **tasks.csv update** - Marks deleted tasks as "deleted" status
- ✅ **90-day retention** - Backups kept for 90 days

**Backup Structure**:
```
workspace/.cleanup-backup/
├── RETENTION_POLICY.txt
└── cleanup-20251008-143022/
    ├── CLEANUP_MANIFEST.txt  ← Deletion log + restoration commands
    ├── TASK-20250929-012/    ← Full workspace backup
    └── PROCESS-20251001-001/
```

**Restoration from Backup**:
```bash
# View backups
ls workspace/.cleanup-backup/

# Restore specific workspace
cp -R workspace/.cleanup-backup/cleanup-{timestamp}/TASK-ID workspace/

# Restore all from a cleanup batch
BACKUP="workspace/.cleanup-backup/cleanup-20251008-143022"
for WS in $BACKUP/*-*/; do
    cp -R "$WS" workspace/
done
```

---

## Recommended Workflows

### Daily Workflow
```bash
# Morning standup: Check active work
/list-workspaces active

# During work: Execute tasks
/execute-task TASK-ID
```

### Weekly Maintenance
```bash
# List all workspaces and review status
/list-workspaces

# Archive completed workspaces
/list-workspaces completed
/archive-workspace TASK-ID  # For each completed

# Review stale workspaces (manual decision)
/list-workspaces stale
# Decide: resume work, archive, or let cleanup handle it
```

### Monthly Cleanup
```bash
# 1. Preview cleanup candidates
/cleanup-workspaces --dry-run

# 2. Review output and execute
/cleanup-workspaces

# 3. Verify clean state
/list-workspaces
```

### Sprint End Routine
```bash
# Complete workflow: archive completed, cleanup abandoned, review remaining

# 1. Archive all completed work
/list-workspaces completed
# Archive each: /archive-workspace TASK-ID

# 2. Clean up abandoned work
/cleanup-workspaces --dry-run  # Preview first
/cleanup-workspaces            # Execute

# 3. Review remaining active work for next sprint
/list-workspaces active
```

---

## Integration with Task Workflow

### Complete Task Lifecycle
```bash
# 1. Create atomic plan
/atomic-plan TASK-20251008-001

# 2. Execute task
/execute-task TASK-20251008-001

# 3. Monitor progress (during execution)
/list-workspaces active

# 4. Archive when complete
/list-workspaces completed
/archive-workspace TASK-20251008-001

# 5. Periodic cleanup (monthly)
/cleanup-workspaces --dry-run
/cleanup-workspaces
```

---

## Troubleshooting

### "No workspaces found"
```bash
# Check workspace directory exists
ls -la workspace/

# Create if missing
mkdir -p workspace
```

### "Workspace not found"
```bash
# List available workspaces
ls workspace/ | grep -E "^[A-Z]+-[0-9]+-[0-9]+$"

# Or use list command
/list-workspaces
```

### "Archive already exists"
```bash
# View existing archives
ls workspace/archive/ | grep TASK-ID

# Rename old archive if needed
mv workspace/archive/TASK-ID-old workspace/archive/TASK-ID-old.backup
```

### "Permission denied"
```bash
# Fix permissions
chmod -R u+w workspace/TASK-ID

# Then retry
/archive-workspace TASK-ID
```

### Accidental deletion
```bash
# Check cleanup backups
ls -lt workspace/.cleanup-backup/

# View deletion manifest
cat workspace/.cleanup-backup/cleanup-{timestamp}/CLEANUP_MANIFEST.txt

# Restore workspace
cp -R workspace/.cleanup-backup/cleanup-{timestamp}/TASK-ID workspace/
```

---

## Testing

Run the test suite to verify commands:

```bash
bash scripts/test-workspace-commands.sh
```

**Tests performed**:
1. Workspace discovery
2. Progress calculation
3. Age calculation
4. Status classification
5. Summary statistics

**Expected output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   WORKSPACE MANAGEMENT COMMANDS - TEST SUITE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Test 1: List Workspaces Discovery
✅ Test 1 Passed: Workspace discovery works

📊 Test 2: Progress Calculation
✅ Test 2 Passed: Progress calculation works

📅 Test 3: Age Calculation
✅ Test 3 Passed: Age calculation works

🏷️  Test 4: Status Classification
✅ Test 4 Passed: Status classification works

📊 Test 5: Summary Statistics
✅ Test 5 Passed: Summary statistics calculated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ALL TESTS PASSED ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## File Reference

- **Command Definitions**:
  - `commands/list-workspaces.md`
  - `commands/archive-workspace.md`
  - `commands/cleanup-workspaces.md`

- **Test Suite**: `scripts/test-workspace-commands.sh`

- **Documentation**: `CLAUDE.md` (Workspace Management section)

- **Created**: 2025-10-08

- **Total Size**: ~45 KB (3 commands + test suite)
