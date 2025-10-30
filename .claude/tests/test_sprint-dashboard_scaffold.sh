#!/usr/bin/env bash
# Test Scaffold: sprint-dashboard
# Generated: 2025-10-30
# Purpose: Validate /sprint-dashboard command functionality

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Helper functions
pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

skip() {
    echo -e "${YELLOW}SKIP${NC}: $1"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

# Test 1: Validate command file exists
test_command_file_exists() {
    echo ""
    echo "Test 1: Command file exists"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -f ".claude/commands/sprint-dashboard.md" ]; then
        pass "Command file found"
    else
        fail "Command file not found: .claude/commands/sprint-dashboard.md"
        return 1
    fi
}

# Test 2: Validate YAML frontmatter
test_yaml_frontmatter() {
    echo ""
    echo "Test 2: YAML frontmatter validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    if ! grep -q "^---$" "$cmd_file"; then
        fail "Missing YAML frontmatter delimiters"
        return 1
    fi

    if ! grep -q "^description:" "$cmd_file"; then
        fail "Missing description field"
        return 1
    fi

    if ! grep -q "^allowed-tools:" "$cmd_file"; then
        fail "Missing allowed-tools field"
        return 1
    fi

    if ! grep -q "^argument-hint:" "$cmd_file"; then
        fail "Missing argument-hint field"
        return 1
    fi

    pass "YAML frontmatter structure valid"
}

# Test 3: Validate allowed-tools
test_allowed_tools() {
    echo ""
    echo "Test 3: Allowed tools validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"
    local tools=$(grep "^allowed-tools:" "$cmd_file" | cut -d':' -f2)

    # Check for required tools
    if echo "$tools" | grep -q "Read"; then
        pass "Read tool declared"
    else
        fail "Read tool not declared"
    fi

    if echo "$tools" | grep -q "Write"; then
        pass "Write tool declared"
    else
        fail "Write tool not declared"
    fi

    if echo "$tools" | grep -q "Bash"; then
        pass "Bash tool declared"
    else
        fail "Bash tool not declared"
    fi

    if echo "$tools" | grep -q "Glob"; then
        pass "Glob tool declared"
    else
        fail "Glob tool not declared"
    fi
}

# Test 4: Validate required sections
test_required_sections() {
    echo ""
    echo "Test 4: Required sections validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"
    local required_sections=(
        "## Overview"
        "## Pre-Execution Validation"
        "## Data Collection Phase"
        "## HTML Dashboard Generation"
        "## Post-Generation Actions"
        "## Expected Outcomes"
        "## Usage Examples"
        "## Troubleshooting"
        "## Integration with Other Commands"
        "## Best Practices"
        "## Success Criteria"
    )

    local missing=0
    for section in "${required_sections[@]}"; do
        if grep -q "$section" "$cmd_file"; then
            pass "Section present: $section"
        else
            fail "Section missing: $section"
            missing=$((missing + 1))
        fi
    done

    if [ $missing -eq 0 ]; then
        pass "All required sections present"
    else
        fail "$missing required sections missing"
    fi
}

# Test 5: Validate bash code blocks
test_bash_code_blocks() {
    echo ""
    echo "Test 5: Bash code blocks validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Count bash code blocks
    local bash_blocks=$(grep -c '```bash' "$cmd_file" || echo 0)

    if [ "$bash_blocks" -gt 0 ]; then
        pass "Found $bash_blocks bash code blocks"
    else
        fail "No bash code blocks found"
    fi

    # Check for critical commands
    if grep -q "mkdir -p" "$cmd_file"; then
        pass "Directory creation command present"
    else
        fail "Directory creation command missing"
    fi

    if grep -q "sed -i" "$cmd_file"; then
        pass "Placeholder replacement commands present"
    else
        fail "Placeholder replacement commands missing"
    fi
}

# Test 6: Validate HTML structure in command
test_html_structure() {
    echo ""
    echo "Test 6: HTML structure validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    if grep -q "<!DOCTYPE html>" "$cmd_file"; then
        pass "HTML DOCTYPE declaration present"
    else
        fail "HTML DOCTYPE declaration missing"
    fi

    if grep -q "</html>" "$cmd_file"; then
        pass "HTML closing tag present"
    else
        fail "HTML closing tag missing"
    fi

    if grep -q "<style>" "$cmd_file"; then
        pass "CSS style block present"
    else
        fail "CSS style block missing"
    fi

    if grep -q "<script>" "$cmd_file"; then
        pass "JavaScript block present"
    else
        fail "JavaScript block missing"
    fi
}

# Test 7: Validate placeholder system
test_placeholders() {
    echo ""
    echo "Test 7: Placeholder system validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    local placeholders=(
        "SPRINT_DATE_PLACEHOLDER"
        "TIMESTAMP_PLACEHOLDER"
        "COMPLETION_RATE_PLACEHOLDER"
        "TOTAL_TASKS_PLACEHOLDER"
        "BACKLOG_COUNT_PLACEHOLDER"
        "INPROGRESS_COUNT_PLACEHOLDER"
        "TESTING_COUNT_PLACEHOLDER"
        "REVIEW_COUNT_PLACEHOLDER"
        "COMPLETE_COUNT_PLACEHOLDER"
        "AUTO_REFRESH_PLACEHOLDER"
    )

    local found=0
    for placeholder in "${placeholders[@]}"; do
        if grep -q "$placeholder" "$cmd_file"; then
            found=$((found + 1))
        fi
    done

    if [ $found -ge 8 ]; then
        pass "Placeholder system implemented ($found placeholders)"
    else
        fail "Incomplete placeholder system ($found placeholders found)"
    fi
}

# Test 8: Validate usage examples
test_usage_examples() {
    echo ""
    echo "Test 8: Usage examples validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check for example commands
    if grep -q "/sprint-dashboard" "$cmd_file"; then
        pass "Command usage examples present"
    else
        fail "Command usage examples missing"
    fi

    # Check for various usage patterns
    if grep -q "\\-\\-auto-refresh" "$cmd_file"; then
        pass "Auto-refresh example present"
    else
        fail "Auto-refresh example missing"
    fi

    if grep -q "\\-\\-theme" "$cmd_file"; then
        pass "Theme example present"
    else
        fail "Theme example missing"
    fi

    if grep -q "\\-\\-open" "$cmd_file"; then
        pass "Open browser example present"
    else
        fail "Open browser example missing"
    fi
}

# Test 9: Validate error handling
test_error_handling() {
    echo ""
    echo "Test 9: Error handling validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check for error conditions
    if grep -q "ERROR:" "$cmd_file"; then
        pass "Error messages present"
    else
        fail "Error messages missing"
    fi

    if grep -q "if \\[ ! -f" "$cmd_file"; then
        pass "File existence checks present"
    else
        fail "File existence checks missing"
    fi

    if grep -q "exit 1" "$cmd_file"; then
        pass "Error exit conditions present"
    else
        fail "Error exit conditions missing"
    fi
}

# Test 10: Validate integration points
test_integration_points() {
    echo ""
    echo "Test 10: Integration points validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check for references to other commands
    if grep -q "/plan-sprint" "$cmd_file"; then
        pass "/plan-sprint integration documented"
    else
        fail "/plan-sprint integration not documented"
    fi

    if grep -q "tasks.csv" "$cmd_file"; then
        pass "tasks.csv integration documented"
    else
        fail "tasks.csv integration not documented"
    fi

    if grep -q ".claude/sprints" "$cmd_file"; then
        pass "Sprint directory structure documented"
    else
        fail "Sprint directory structure not documented"
    fi
}

# Test 11: Functional test - Generate dashboard (if data available)
test_functional_dashboard_generation() {
    echo ""
    echo "Test 11: Functional dashboard generation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if test data exists
    if [ ! -d ".claude/sprints" ]; then
        skip "No sprint data available - skipping functional test"
        return 0
    fi

    # Find any sprint file
    local sprint_file=$(ls .claude/sprints/sprint-*.md 2>/dev/null | head -1)
    if [ -z "$sprint_file" ]; then
        skip "No sprint files found - skipping functional test"
        return 0
    fi

    local sprint_date=$(basename "$sprint_file" .md | sed 's/sprint-//')

    # Check if dashboard can be generated (dry run check)
    local backlog=".claude/sprints/sprint-${sprint_date}-backlog.csv"
    if [ -f "$backlog" ]; then
        pass "Sprint data structure valid for generation"
    else
        fail "Sprint backlog missing: $backlog"
    fi

    # Note: Actual generation would require running the command
    # which is out of scope for this scaffold
    skip "Full dashboard generation test requires command execution"
}

# Test 12: Validate CSS factory theme
test_css_factory_theme() {
    echo ""
    echo "Test 12: CSS factory theme validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check for factory theme CSS variables
    if grep -q "\\-\\-factory-bg" "$cmd_file"; then
        pass "Factory CSS variables present"
    else
        fail "Factory CSS variables missing"
    fi

    if grep -q "conveyor-belt" "$cmd_file"; then
        pass "Conveyor belt styling present"
    else
        fail "Conveyor belt styling missing"
    fi

    if grep -q "@keyframes" "$cmd_file"; then
        pass "CSS animations present"
    else
        fail "CSS animations missing"
    fi

    if grep -q ".station" "$cmd_file"; then
        pass "Station styling present"
    else
        fail "Station styling missing"
    fi
}

# Test 13: Validate JavaScript functionality
test_javascript_functionality() {
    echo ""
    echo "Test 13: JavaScript functionality validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check for key JavaScript functions
    if grep -q "function.*Filter" "$cmd_file"; then
        pass "Filter functions present"
    else
        fail "Filter functions missing"
    fi

    if grep -q "addEventListener" "$cmd_file"; then
        pass "Event listeners present"
    else
        fail "Event listeners missing"
    fi

    if grep -q "autoRefresh" "$cmd_file" || grep -q "startAutoRefresh" "$cmd_file"; then
        pass "Auto-refresh functionality present"
    else
        fail "Auto-refresh functionality missing"
    fi

    if grep -q "modal" "$cmd_file"; then
        pass "Modal functionality present"
    else
        fail "Modal functionality missing"
    fi
}

# Test 14: Validate responsive design
test_responsive_design() {
    echo ""
    echo "Test 14: Responsive design validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check for media queries
    if grep -q "@media" "$cmd_file"; then
        pass "Media queries present"
    else
        fail "Media queries missing"
    fi

    # Check for mobile-friendly features
    if grep -q "max-width.*768" "$cmd_file" || grep -q "min-width.*768" "$cmd_file"; then
        pass "Mobile breakpoint defined"
    else
        fail "Mobile breakpoint not defined"
    fi
}

# Test 15: Validate documentation completeness
test_documentation_completeness() {
    echo ""
    echo "Test 15: Documentation completeness validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local cmd_file=".claude/commands/sprint-dashboard.md"

    # Check word count as proxy for completeness
    local word_count=$(wc -w < "$cmd_file" | tr -d ' ')

    if [ "$word_count" -gt 3000 ]; then
        pass "Documentation is comprehensive ($word_count words)"
    else
        fail "Documentation may be incomplete ($word_count words)"
    fi

    # Check for troubleshooting section content
    local troubleshooting_lines=$(sed -n '/## Troubleshooting/,/^## /p' "$cmd_file" | wc -l | tr -d ' ')

    if [ "$troubleshooting_lines" -gt 20 ]; then
        pass "Troubleshooting section is detailed"
    else
        fail "Troubleshooting section may be incomplete"
    fi
}

# Run all tests
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "    SPRINT DASHBOARD COMMAND TEST SUITE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Change to repository root if not already there
    if [ ! -d ".claude" ]; then
        echo "ERROR: Must be run from repository root"
        exit 1
    fi

    # Run all tests
    test_command_file_exists
    test_yaml_frontmatter
    test_allowed_tools
    test_required_sections
    test_bash_code_blocks
    test_html_structure
    test_placeholders
    test_usage_examples
    test_error_handling
    test_integration_points
    test_functional_dashboard_generation
    test_css_factory_theme
    test_javascript_functionality
    test_responsive_design
    test_documentation_completeness

    # Print summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                  TEST SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${GREEN}Passed:${NC}  $TESTS_PASSED"
    echo -e "${RED}Failed:${NC}  $TESTS_FAILED"
    echo -e "${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    echo "Total tests run: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 1
    fi
}

# Run main function
main
