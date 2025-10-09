# Task Workspace: TASK-20251008-004

**Title**: Patch atomic-plan.md with Input Validation
**Started**: 2025-10-09
**Priority**: CRITICAL
**Estimated Effort**: 0.094 days (90 minutes)
**Status**: Planning Complete

---

## Overview

This workspace contains the execution plan for patching the `/atomic-plan` command with input validation to prevent command injection attacks (CWE-78). The task integrates the validation library created in TASK-20251008-003.

## Files

- `atomic-plan-TASK-20251008-004.md` - Detailed 5-phase execution plan
- `checklist-TASK-20251008-004.md` - 15-item execution checklist
- `notes.md` - Session notes and observations
- `README.md` - This file

## Quick Start

### Begin Implementation

```bash
# 1. Verify dependency completed
test -f .claude/lib/input-validation.sh && echo "✅ Library exists"

# 2. Verify on correct branch
git branch --show-current  # Should be: infrastructure/critical-setup-20251008

# 3. Start execution
cat .claude/workspace/TASK-20251008-004/atomic-plan-TASK-20251008-004.md
```

### Track Progress

```bash
# View checklist
cat .claude/workspace/TASK-20251008-004/checklist-TASK-20251008-004.md

# Count completed items
grep "\[x\]" .claude/workspace/TASK-20251008-004/checklist-TASK-20251008-004.md | wc -l

# Count remaining items
grep "\[ \]" .claude/workspace/TASK-20251008-004/checklist-TASK-20251008-004.md | wc -l
```

### After Completion

```bash
# Update task status in tasks.csv
sed -i '' "s/TASK-20251008-004,\([^,]*\),pending,/TASK-20251008-004,\1,completed,/" tasks.csv

# Verify update
grep "^TASK-20251008-004," tasks.csv

# Move to next task
/atomic-plan TASK-20251008-005
```

---

## Success Criteria

- [ ] Input validation library sourced at command start
- [ ] All TASK_ID values validated before use
- [ ] Malicious inputs rejected with clear errors
- [ ] Valid inputs continue to work
- [ ] File existence checks added for tasks.csv
- [ ] Atomic commit created
- [ ] Manual testing confirms injection attacks blocked
- [ ] Command still generates plans successfully

---

## Security Context

**Vulnerability**: Command Injection (CWE-78)
**OWASP Category**: A03:2021 - Injection
**Current Risk**: CRITICAL
**Post-Fix Risk**: LOW

**Attack Vectors to Block**:
1. Semicolon injection: `TASK-001; rm -rf /`
2. Backtick injection: `` TASK-`whoami`-001 ``
3. Command substitution: `TASK-$(whoami)-001`
4. Path traversal: `../../../etc/passwd`

---

## Implementation Phases

1. **Preparation** (10 min) - Verify dependencies, create backup
2. **Implementation** (60 min) - Add validation code
3. **Integration & Testing** (15 min) - Test valid/malicious inputs
4. **Finalization** (5 min) - Clean up and commit
5. **Documentation** (parallel) - Update notes

**Total Estimated Time**: 90 minutes

---

## Key Code Changes

### Before (Vulnerable)
```bash
TASK_ID="${1:-$(grep ",pending," tasks.csv | head -1 | cut -d',' -f1)}"
TASK_ROW=$(grep "^$TASK_ID," tasks.csv)
WORKSPACE_DIR=".claude/workspace/$TASK_ID"
```

### After (Secured)
```bash
source .claude/lib/input-validation.sh
TASK_ID="${1}"
validate_task_id "$TASK_ID" || exit 1
validate_file_readable "tasks.csv" || exit 1
TASK_ROW=$(grep "^$TASK_ID," tasks.csv)
WORKSPACE_DIR=$(validate_workspace_dir "$TASK_ID") || exit 1
```

---

## Dependencies

**Completed**:
- ✅ TASK-20251008-001: Git repository initialized
- ✅ TASK-20251008-002: tasks.csv created
- ✅ TASK-20251008-003: Input validation library created

**Blocks**:
- TASK-20251008-005: Patch execute-task.md (same pattern)

---

## Rollback Procedure

If implementation fails or breaks the command:

```bash
# Option 1: Git reset (if committed)
git reset --hard HEAD~1

# Option 2: Git checkout (if not committed)
git checkout commands/atomic-plan.md

# Option 3: Restore from backup
cp commands/atomic-plan.md.backup-20251008 commands/atomic-plan.md
```

---

## Testing Commands

### Test Valid Input
```bash
/atomic-plan TASK-20251008-003  # Should work
```

### Test Attack Vectors
```bash
/atomic-plan "TASK-001; rm -rf /"  # Should be blocked
/atomic-plan 'TASK-`whoami`-001'   # Should be blocked
/atomic-plan "../../../etc/passwd"  # Should be blocked
```

### Test All Prefixes
```bash
for PREFIX in TASK ARCH HOTFIX DEVOPS MTENANT PROCESS; do
    source .claude/lib/input-validation.sh
    validate_task_id "${PREFIX}-20251008-001" && echo "✅ $PREFIX"
done
```

---

## References

- **Atomic Plan**: `atomic-plan-TASK-20251008-004.md` (full implementation details)
- **Code Review**: `docs/code-review-reports/code-review-agent_2025-10-08-15.md` (lines 110-176)
- **Validation Library**: `.claude/lib/input-validation.sh`
- **Target File**: `commands/atomic-plan.md`

---

**Workspace Created**: 2025-10-09
**Ready for Execution**: Yes ✅
