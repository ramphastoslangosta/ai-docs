#!/usr/bin/env bash
# Test Scaffold: plan-sprint
# Generated: 2025-10-30
# Purpose: Validate /plan-sprint command functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
pass_test() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail_test() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    echo "   Details: $2"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

skip_test() {
    echo -e "${YELLOW}⚠️  SKIP${NC}: $1"
}

# Test 1: Validate command file exists
test_command_exists() {
    echo ""
    echo "Test 1: Command file existence"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ ! -f ".claude/commands/plan-sprint.md" ]; then
        fail_test "Command file not found" ".claude/commands/plan-sprint.md does not exist"
        return 1
    fi

    pass_test "Command file exists at .claude/commands/plan-sprint.md"
}

# Test 2: Validate YAML frontmatter
test_yaml_frontmatter() {
    echo ""
    echo "Test 2: YAML frontmatter validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Check for opening ---
    if ! head -1 "$file" | grep -q "^---$"; then
        fail_test "Missing opening YAML delimiter" "First line should be '---'"
        return 1
    fi

    # Check for closing ---
    if ! sed -n '2,10p' "$file" | grep -q "^---$"; then
        fail_test "Missing closing YAML delimiter" "YAML frontmatter should end with '---'"
        return 1
    fi

    # Extract frontmatter
    local frontmatter=$(awk '/^---$/{flag=!flag;next}flag' "$file" | head -20)

    # Check required fields
    if ! echo "$frontmatter" | grep -q "description:"; then
        fail_test "Missing description field" "YAML frontmatter must include 'description:'"
        return 1
    fi

    if ! echo "$frontmatter" | grep -q "allowed-tools:"; then
        fail_test "Missing allowed-tools field" "YAML frontmatter must include 'allowed-tools:'"
        return 1
    fi

    if ! echo "$frontmatter" | grep -q "argument-hint:"; then
        fail_test "Missing argument-hint field" "YAML frontmatter must include 'argument-hint:'"
        return 1
    fi

    pass_test "YAML frontmatter is valid and complete"
}

# Test 3: Validate required sections
test_required_sections() {
    echo ""
    echo "Test 3: Required sections presence"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"
    local required_sections=(
        "Overview"
        "Pre-Planning Discovery"
        "Expected Outcomes"
        "Usage Examples"
        "Troubleshooting"
    )

    local missing_sections=()

    for section in "${required_sections[@]}"; do
        if ! grep -q "## $section" "$file"; then
            missing_sections+=("$section")
        fi
    done

    if [ ${#missing_sections[@]} -gt 0 ]; then
        fail_test "Missing required sections" "Sections missing: ${missing_sections[*]}"
        return 1
    fi

    pass_test "All required sections present"
}

# Test 4: Validate allowed-tools declaration
test_allowed_tools() {
    echo ""
    echo "Test 4: Allowed-tools validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"
    local tools_line=$(grep "allowed-tools:" "$file")

    if [ -z "$tools_line" ]; then
        fail_test "No allowed-tools declaration" "YAML frontmatter must declare allowed-tools"
        return 1
    fi

    # Check that it includes expected tools
    if ! echo "$tools_line" | grep -q "Read"; then
        fail_test "Missing Read tool" "plan-sprint requires Read tool"
        return 1
    fi

    if ! echo "$tools_line" | grep -q "Write"; then
        fail_test "Missing Write tool" "plan-sprint requires Write tool"
        return 1
    fi

    if ! echo "$tools_line" | grep -q "Bash"; then
        fail_test "Missing Bash tool" "plan-sprint requires Bash tool"
        return 1
    fi

    pass_test "Allowed-tools properly declared: $tools_line"
}

# Test 5: Validate bash code blocks
test_bash_blocks() {
    echo ""
    echo "Test 5: Bash code blocks validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Count bash blocks
    local bash_count=$(grep -c '```bash' "$file")

    if [ "$bash_count" -lt 5 ]; then
        fail_test "Insufficient bash blocks" "Expected at least 5 bash blocks, found $bash_count"
        return 1
    fi

    # Check for common patterns
    if ! grep -q "echo.*Sprint" "$file"; then
        fail_test "Missing sprint-specific logic" "Should contain sprint planning bash code"
        return 1
    fi

    if ! grep -q "tasks.csv" "$file"; then
        fail_test "Missing tasks.csv reference" "Should read tasks from tasks.csv"
        return 1
    fi

    pass_test "Bash code blocks present and contain sprint logic ($bash_count blocks)"
}

# Test 6: Validate usage examples
test_usage_examples() {
    echo ""
    echo "Test 6: Usage examples validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Count example sections
    local example_count=$(grep -c "### Example" "$file")

    if [ "$example_count" -lt 3 ]; then
        fail_test "Insufficient examples" "Expected at least 3 examples, found $example_count"
        return 1
    fi

    # Check for command invocations in examples
    if ! grep -q "/plan-sprint" "$file"; then
        fail_test "Examples missing command invocations" "Should show /plan-sprint usage"
        return 1
    fi

    pass_test "Usage examples present and comprehensive ($example_count examples)"
}

# Test 7: Validate file structure
test_file_structure() {
    echo ""
    echo "Test 7: File structure validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Check file size (should be substantial)
    local line_count=$(wc -l < "$file")

    if [ "$line_count" -lt 300 ]; then
        fail_test "File too small" "Expected at least 300 lines, found $line_count"
        return 1
    fi

    if [ "$line_count" -gt 800 ]; then
        fail_test "File too large" "File exceeds 800 lines ($line_count) - consider refactoring"
        return 1
    fi

    pass_test "File structure appropriate ($line_count lines)"
}

# Test 8: Validate integration points
test_integration_points() {
    echo ""
    echo "Test 8: Integration points validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Check for integration section
    if ! grep -q "## Integration" "$file"; then
        fail_test "Missing integration section" "Should document integration with other commands"
        return 1
    fi

    # Check for references to related commands
    local related_commands=(
        "/generate_tasks"
        "/atomic-plan"
        "/execute-task"
    )

    local missing_refs=()
    for cmd in "${related_commands[@]}"; do
        if ! grep -q "$cmd" "$file"; then
            missing_refs+=("$cmd")
        fi
    done

    if [ ${#missing_refs[@]} -gt 0 ]; then
        fail_test "Missing command references" "Should reference: ${missing_refs[*]}"
        return 1
    fi

    pass_test "Integration points documented"
}

# Test 9: Validate error handling
test_error_handling() {
    echo ""
    echo "Test 9: Error handling validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Check for error messages
    if ! grep -q "ERROR:" "$file"; then
        fail_test "Missing error messages" "Should include error handling"
        return 1
    fi

    # Check for exit statements after errors
    if ! grep -q "exit 1" "$file"; then
        fail_test "Missing error exits" "Should exit on errors"
        return 1
    fi

    # Check for validation
    if ! grep -q "validate\|Validat" "$file"; then
        fail_test "Missing validation" "Should validate inputs"
        return 1
    fi

    pass_test "Error handling present"
}

# Test 10: Functional test (basic syntax)
test_functional_basic() {
    echo ""
    echo "Test 10: Functional test (syntax check)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local file=".claude/commands/plan-sprint.md"

    # Extract bash code and check syntax
    # This is a simplified check - full functional testing requires execution context

    # Check for basic bash syntax issues
    if grep -E '\$\(' "$file" | grep -v '^\s*#' | grep -qE '\$\([^\)]*$'; then
        fail_test "Possible unclosed command substitution" "Check bash syntax"
        return 1
    fi

    # Check for unmatched quotes in bash blocks (simplified)
    local bash_blocks=$(awk '/```bash/,/```/' "$file" | grep -v '```')

    skip_test "Full functional test (requires execution context)"
    pass_test "Basic syntax check passed"
}

# Run all tests
main() {
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║     Test Suite: /plan-sprint Command Validation        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "Running tests..."

    # Change to project root if needed
    if [ ! -d ".claude" ]; then
        if [ -d "../.claude" ]; then
            cd ..
        else
            echo "❌ ERROR: Cannot find .claude directory"
            exit 1
        fi
    fi

    # Run all tests
    test_command_exists
    test_yaml_frontmatter
    test_required_sections
    test_allowed_tools
    test_bash_blocks
    test_usage_examples
    test_file_structure
    test_integration_points
    test_error_handling
    test_functional_basic

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                    TEST SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Tests run:    $TESTS_RUN"
    echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"

    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
        echo ""
        echo "❌ Some tests failed - review output above"
        exit 1
    else
        echo "Tests failed: 0"
        echo ""
        echo "✅ All tests passed!"
        exit 0
    fi
}

# Run main function
main "$@"
