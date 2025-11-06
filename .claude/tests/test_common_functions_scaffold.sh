#!/bin/bash
# Test suite for common-functions.sh library
# Task: ARCH-20251103-001
# Created: 2025-11-03
# Updated: 2025-11-05

set -e

# Source the library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common-functions.sh"

echo "🧪 Testing common-functions.sh library"
echo "========================================"
echo ""
echo "📦 Library version: $COMMON_FUNCTIONS_VERSION"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for test assertions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"

    if [ "$expected" = "$actual" ]; then
        echo "  ✅ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "  ❌ $test_name"
        echo "     Expected: '$expected'"
        echo "     Got:      '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"

    if echo "$haystack" | grep -q "$needle"; then
        echo "  ✅ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "  ❌ $test_name"
        echo "     Expected to find: '$needle'"
        echo "     In: '$haystack'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# =============================================================================
# Test 1: get_workspace_progress()
# =============================================================================
echo "Test 1: get_workspace_progress()"

# Test 1a: Normal progress calculation
TEST_WS="/tmp/test-workspace-$$"
mkdir -p "$TEST_WS"
cat > "$TEST_WS/checklist-TEST-001.md" << 'EOF'
- [x] Step 1 complete
- [x] Step 2 complete
- [ ] Step 3 pending
- [ ] Step 4 pending
EOF

RESULT=$(get_workspace_progress "TEST-001" "$TEST_WS")
assert_equals "2/4 (50%)" "$RESULT" "Returns correct progress for 2/4 items"

# Test 1b: Missing checklist file
rm "$TEST_WS/checklist-TEST-001.md"
RESULT=$(get_workspace_progress "TEST-001" "$TEST_WS")
assert_equals "0/0 (0%)" "$RESULT" "Returns 0/0 for missing checklist"

# Test 1c: 100% completion
cat > "$TEST_WS/checklist-TEST-002.md" << 'EOF'
- [x] All done
- [x] Completed
EOF

RESULT=$(get_workspace_progress "TEST-002" "$TEST_WS")
assert_equals "2/2 (100%)" "$RESULT" "Returns 100% for fully completed"

# Test 1d: 0% completion
cat > "$TEST_WS/checklist-TEST-003.md" << 'EOF'
- [ ] Not started
- [ ] Pending
EOF

RESULT=$(get_workspace_progress "TEST-003" "$TEST_WS")
assert_equals "0/2 (0%)" "$RESULT" "Returns 0% for no progress"

rm -rf "$TEST_WS"

# =============================================================================
# Test 2: update_task_status()
# =============================================================================
echo ""
echo "Test 2: update_task_status()"

# Test 2a: Update status successfully
TEST_CSV="/tmp/test-tasks-$$.csv"
cat > "$TEST_CSV" << 'EOF'
task_id,title,description,priority,status,phase
TEST-001,Test Task,Description,high,pending,phase-1
TEST-002,Another Task,Desc,medium,in-progress,phase-2
EOF

update_task_status "TEST-001" "completed" "$TEST_CSV" > /dev/null 2>&1
RESULT=$(grep "^TEST-001," "$TEST_CSV" | cut -d',' -f5)
assert_equals "completed" "$RESULT" "Updates status to completed"

# Test 2b: Update to different statuses
update_task_status "TEST-002" "blocked" "$TEST_CSV" > /dev/null 2>&1
RESULT=$(grep "^TEST-002," "$TEST_CSV" | cut -d',' -f5)
assert_equals "blocked" "$RESULT" "Updates status to blocked"

# Test 2c: Invalid status (should fail gracefully)
if update_task_status "TEST-001" "invalid-status" "$TEST_CSV" > /dev/null 2>&1; then
    echo "  ❌ Should reject invalid status"
    ((TESTS_FAILED++))
else
    echo "  ✅ Rejects invalid status values"
    ((TESTS_PASSED++))
fi

# Test 2d: Planning status (new status added)
update_task_status "TEST-001" "planning" "$TEST_CSV" > /dev/null 2>&1
RESULT=$(grep "^TEST-001," "$TEST_CSV" | cut -d',' -f5)
assert_equals "planning" "$RESULT" "Supports planning status"

rm "$TEST_CSV"

# =============================================================================
# Test 3: update_checklist_item()
# =============================================================================
echo ""
echo "Test 3: update_checklist_item()"

# Test 3a: Mark item as complete
TEST_CHECKLIST="/tmp/test-checklist-$$.md"
cat > "$TEST_CHECKLIST" << 'EOF'
- [ ] Create library file
- [ ] Add documentation
- [x] Setup environment
EOF

update_checklist_item "$TEST_CHECKLIST" "Create library" "complete" > /dev/null 2>&1
if grep -q "^\- \[x\] Create library" "$TEST_CHECKLIST"; then
    echo "  ✅ Marks item as complete"
    ((TESTS_PASSED++))
else
    echo "  ❌ Failed to mark item complete"
    ((TESTS_FAILED++))
fi

# Test 3b: Mark item as incomplete
update_checklist_item "$TEST_CHECKLIST" "Setup environment" "incomplete" > /dev/null 2>&1
if grep -q "^\- \[ \] Setup environment" "$TEST_CHECKLIST"; then
    echo "  ✅ Marks item as incomplete"
    ((TESTS_PASSED++))
else
    echo "  ❌ Failed to mark item incomplete"
    ((TESTS_FAILED++))
fi

# Test 3c: Partial text matching
cat > "$TEST_CHECKLIST" << 'EOF'
- [ ] Implement comprehensive testing framework
EOF

update_checklist_item "$TEST_CHECKLIST" "testing" "complete" > /dev/null 2>&1
if grep -q "^\- \[x\].*testing" "$TEST_CHECKLIST"; then
    echo "  ✅ Supports partial text matching"
    ((TESTS_PASSED++))
else
    echo "  ❌ Partial matching failed"
    ((TESTS_FAILED++))
fi

rm "$TEST_CHECKLIST"

# =============================================================================
# Test 4: append_note()
# =============================================================================
echo ""
echo "Test 4: append_note()"

# Test 4a: Append note to new file
TEST_NOTES="/tmp/test-notes-$$.md"
append_note "Test note entry" "$TEST_NOTES" > /dev/null 2>&1

if [ -f "$TEST_NOTES" ]; then
    echo "  ✅ Creates notes file if missing"
    ((TESTS_PASSED++))
else
    echo "  ❌ Failed to create notes file"
    ((TESTS_FAILED++))
fi

# Test 4b: Note contains timestamp
if grep -q "\*\*\[.*\]\*\* Test note entry" "$TEST_NOTES"; then
    echo "  ✅ Adds timestamp to note"
    ((TESTS_PASSED++))
else
    echo "  ❌ Missing timestamp"
    ((TESTS_FAILED++))
fi

# Test 4c: Multiple notes append correctly
append_note "Second note" "$TEST_NOTES" > /dev/null 2>&1
LINE_COUNT=$(grep -c "Test note entry\|Second note" "$TEST_NOTES")
if [ "$LINE_COUNT" -eq 2 ]; then
    echo "  ✅ Appends multiple notes"
    ((TESTS_PASSED++))
else
    echo "  ❌ Multiple notes failed (expected 2, got $LINE_COUNT)"
    ((TESTS_FAILED++))
fi

rm "$TEST_NOTES"

# =============================================================================
# Test 5: git_commit_with_message()
# =============================================================================
echo ""
echo "Test 5: git_commit_with_message()"

# Test 5a: Create commit successfully
TEST_GIT="/tmp/test-git-$$"
mkdir -p "$TEST_GIT"
cd "$TEST_GIT"
git init > /dev/null 2>&1
git config user.email "test@example.com" > /dev/null 2>&1
git config user.name "Test User" > /dev/null 2>&1
echo "test content" > test.txt

git_commit_with_message "test: initial commit" "test.txt" "TEST-001" > /dev/null 2>&1
COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
assert_equals "1" "$COMMIT_COUNT" "Creates git commit"

# Test 5b: Task ID appended to commit message
COMMIT_MSG=$(git log -1 --format=%B)
assert_contains "$COMMIT_MSG" "Task: TEST-001" "Appends task ID to commit message"

# Test 5c: No changes to commit
git_commit_with_message "test: no changes" "" "" > /dev/null 2>&1
COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
assert_equals "1" "$COMMIT_COUNT" "Handles no changes gracefully"

# Test 5d: Filename with spaces (security fix verification)
echo "content with spaces" > "file with spaces.txt"
git_commit_with_message "test: file with spaces" "file with spaces.txt" > /dev/null 2>&1
COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
assert_equals "2" "$COMMIT_COUNT" "Handles filenames with spaces"

cd - > /dev/null
rm -rf "$TEST_GIT"

# =============================================================================
# Test 6: format_duration()
# =============================================================================
echo ""
echo "Test 6: format_duration()"

# Test 6a: Format 90 seconds
RESULT=$(format_duration 90)
assert_equals "1m 30s" "$RESULT" "Formats 90 seconds as 1m 30s"

# Test 6b: Format 7530 seconds (2h 5m 30s)
RESULT=$(format_duration 7530)
assert_equals "2h 5m 30s" "$RESULT" "Formats 7530s as 2h 5m 30s"

# Test 6c: Format 90000 seconds (1d 1h 0m 0s)
RESULT=$(format_duration 90000)
assert_equals "1d 1h 0m 0s" "$RESULT" "Formats 90000s as 1d 1h 0m 0s"

# Test 6d: Format 0 seconds
RESULT=$(format_duration 0)
assert_equals "0s" "$RESULT" "Formats 0s correctly"

# Test 6e: Format 3661 seconds (1h 1m 1s)
RESULT=$(format_duration 3661)
assert_equals "1h 1m 1s" "$RESULT" "Formats 3661s as 1h 1m 1s"

# Test 6f: Invalid input (non-numeric)
if format_duration "abc" > /dev/null 2>&1; then
    echo "  ❌ Should reject non-numeric input"
    ((TESTS_FAILED++))
else
    echo "  ✅ Rejects non-numeric input"
    ((TESTS_PASSED++))
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "========================================"
echo "📊 Test Results Summary"
echo "========================================"
echo "✅ Tests passed: $TESTS_PASSED"
echo "❌ Tests failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
    echo "❌ TEST SUITE FAILED"
    exit 1
else
    echo "✅ ALL TESTS PASSED"
    echo ""
    echo "Coverage: 6/6 functions tested"
    echo "Total test cases: $TESTS_PASSED"
    exit 0
fi
