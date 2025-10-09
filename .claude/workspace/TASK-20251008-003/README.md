# Task Workspace: TASK-20251008-003
## Add Input Validation Library

**Created**: 2025-10-09
**Task Type**: Security Implementation
**Priority**: CRITICAL
**Phase**: 1/3 (Critical Infrastructure & Security)

---

## Quick Reference

**Task ID**: TASK-20251008-003
**Title**: Add Input Validation Library
**Branch**: infrastructure/critical-setup-20251008
**Estimated Effort**: 3 hours
**Dependencies**: TASK-20251008-001 (Initialize Git Repository)

---

## Objective

Create a comprehensive bash input validation library (.claude/lib/input-validation.sh) to prevent command injection and path traversal vulnerabilities across the AI-docs task management system.

**Security Context**: This task addresses 21 command injection vulnerabilities (CWE-78, OWASP A03:2021) identified in the code review report.

---

## Files in This Workspace

- **atomic-plan-TASK-20251008-003.md** - Detailed step-by-step implementation plan
- **checklist-TASK-20251008-003.md** - Progress tracking checklist (95 items)
- **notes.md** - Session notes and observations
- **README.md** - This file (quick reference guide)

---

## Implementation Overview

### Deliverables

1. **.claude/lib/input-validation.sh** - Main validation library with 4 functions:
   - `validate_task_id()` - Regex validation for TASK_ID format
   - `sanitize_path()` - Path canonicalization and traversal prevention
   - `validate_workspace_dir()` - Combined TASK_ID + path validation
   - `validate_file_readable()` - File existence and permission checks

2. **.claude/lib/input-validation-example.sh** - Usage example for slash commands

### Security Improvements

**Before**: User-provided TASK_ID values directly interpolated into bash commands
```bash
# VULNERABLE
TASK_ID="${1}"
mkdir -p ".claude/workspace/$TASK_ID"  # Command injection possible
```

**After**: All inputs validated before use
```bash
# SECURED
source .claude/lib/input-validation.sh
TASK_ID="${1}"
validate_task_id "$TASK_ID" || exit 1  # Validation gate
WORKSPACE_DIR=$(validate_workspace_dir "$TASK_ID") || exit 1
mkdir -p "$WORKSPACE_DIR"  # Safe
```

---

## Execution Phases

### Phase 1: Preparation (16 minutes)
- Verify dependencies
- Create workspace and library directories
- Review reference implementation
- Checkout feature branch

### Phase 2: Implementation (90 minutes)
- Create library file with header
- Implement 4 validation functions
- Test each function independently
- Atomic commits per function

### Phase 3: Finalization (30 minutes)
- Export all functions
- Run comprehensive test suite
- Create usage example
- Performance validation

### Phase 4: Documentation & Commit (20 minutes)
- Update workspace notes
- Final commit with all changes
- Update tasks.csv status

**Total Time**: 3 hours 6 minutes

---

## Testing Strategy

### Unit Tests (Per Function)
- Valid inputs accepted
- Invalid inputs rejected
- Error messages clear
- Edge cases handled

### Security Tests (Attack Vectors)
- Semicolon injection: `TASK-001; rm -rf /`
- Backtick injection: `TASK-\`whoami\`-001`
- Command substitution: `TASK-$(whoami)-001`
- Path traversal: `../../../etc/passwd`
- Absolute path escape: `/etc/passwd`
- Empty strings
- Null bytes

### Integration Tests
- Library sources from multiple directories
- Functions available after export
- No conflicts with existing code
- Performance acceptable (<1ms per validation)

---

## Success Criteria

All of the following must be true before marking task complete:

1. All 4 validation functions implemented and tested
2. All functions exported and available after sourcing
3. All attack vectors blocked (7 attack scenarios)
4. Usage example demonstrates correct integration
5. Documentation comments complete
6. Git commits atomic and descriptive
7. tasks.csv updated to "completed"
8. Ready for integration in TASK-004 and TASK-005

---

## Quick Start Commands

### Execute Full Plan
```bash
cd /Users/rafaellang/ai-docs
# Follow atomic-plan-TASK-20251008-003.md step by step
```

### Test Library After Creation
```bash
cd /Users/rafaellang/ai-docs
source .claude/lib/input-validation.sh

# Test valid input
validate_task_id "TASK-20251008-003" && echo "PASS"

# Test malicious input (should fail)
validate_task_id "TASK-001; rm -rf /" && echo "FAIL" || echo "BLOCKED"
```

### Check Progress
```bash
# Count completed checklist items
grep "\[x\]" checklist-TASK-20251008-003.md | wc -l

# Count total items
grep -E "\[ \]|\[x\]" checklist-TASK-20251008-003.md | wc -l

# Calculate percentage
# completed / total * 100
```

---

## Rollback Procedures

### Rollback Single Commit
```bash
git reset --soft HEAD~1
```

### Rollback Entire Task
```bash
rm -rf .claude/lib/input-validation*.sh
git checkout tasks.csv
rm -rf .claude/workspace/TASK-20251008-003
```

### Emergency Rollback (All Changes)
```bash
git checkout main -- .claude/lib/
sed -i '' 's/TASK-20251008-003,[^,]*,[^,]*,[^,]*,completed,/TASK-20251008-003,\1,\2,\3,pending,/' tasks.csv
```

---

## Dependencies

### Prerequisites (Must Be Complete)
- TASK-20251008-001: Initialize Git Repository - **COMPLETED**

### Blocked Tasks (Waiting for This)
- TASK-20251008-004: Patch atomic-plan.md with Input Validation
- TASK-20251008-005: Patch execute-task.md with Input Validation

### Related Tasks
- TASK-20251008-006: Harden Permissions in settings.local.json

---

## Reference Materials

### Code Review Report
- File: `/Users/rafaellang/ai-docs/docs/code-review-reports/code-review-agent_2025-10-08-15.md`
- Lines 110-176: Command injection vulnerability analysis
- Lines 646-730: Complete reference implementation

### OWASP References
- **A03:2021 - Injection**: [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- **CWE-78**: OS Command Injection

### Internal Documentation
- CLAUDE.md: System overview and best practices
- settings.local.json: Permissions configuration

---

## Troubleshooting

### Issue: Git not initialized
**Symptom**: `git status` returns error
**Solution**: Run TASK-20251008-001 first
```bash
cd /Users/rafaellang/ai-docs
git init
```

### Issue: realpath command not found
**Symptom**: sanitize_path() fails with "command not found"
**Solution**: Install coreutils (realpath is built-in on macOS 10.15+)
```bash
brew install coreutils  # If needed
```

### Issue: Functions not exported
**Symptom**: `type validate_task_id` returns "not found"
**Solution**: Ensure export statements are at end of file
```bash
grep "export -f" .claude/lib/input-validation.sh
```

### Issue: Tests fail unexpectedly
**Symptom**: Valid inputs rejected
**Solution**: Check regex pattern is correctly escaped
```bash
# Verify pattern
echo "$TASK_ID_PATTERN"
# Should be: ^(TASK|ARCH|HOTFIX|DEVOPS|MTENANT|PROCESS)-[0-9]{8}-[0-9]{3}$
```

---

## Next Steps After Completion

1. Mark TASK-20251008-003 as "completed" in tasks.csv
2. Begin TASK-20251008-004 (Patch atomic-plan.md)
3. Begin TASK-20251008-005 (Patch execute-task.md)
4. Test integration across all slash commands
5. Update security documentation

---

## Notes

- This is the foundation for all subsequent security improvements
- All slash commands will eventually source this library
- The library has zero external dependencies (pure bash)
- Performance impact is negligible (<1ms per validation)
- Library follows defensive programming principles (fail secure)

---

**Task Status**: Pending
**Last Updated**: 2025-10-09
**Next Review**: After implementation complete
