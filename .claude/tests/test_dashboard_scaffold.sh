#!/usr/bin/env bash
# Test Scaffold: dashboard
# Generated: 2025-10-30
# Purpose: Validate /dashboard command functionality

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

# Helper functions
pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

skip() {
    echo -e "${YELLOW}⚠️  SKIP${NC}: $1"
}

info() {
    echo -e "${YELLOW}ℹ️  INFO${NC}: $1"
}

# Test 1: Validate command file exists
test_command_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 1: Validate command file exists"

    if [ -f ".claude/commands/dashboard.md" ]; then
        pass "Command file exists at .claude/commands/dashboard.md"
    else
        fail "Command file not found at .claude/commands/dashboard.md"
        return 1
    fi
}

# Test 2: Validate YAML frontmatter
test_yaml_frontmatter() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 2: Validate YAML frontmatter"

    if ! grep -q "^---$" ".claude/commands/dashboard.md"; then
        fail "Missing YAML frontmatter delimiters"
        return 1
    fi

    if ! grep -q "^description:" ".claude/commands/dashboard.md"; then
        fail "Missing 'description' field in YAML frontmatter"
        return 1
    fi

    if ! grep -q "^allowed-tools:" ".claude/commands/dashboard.md"; then
        fail "Missing 'allowed-tools' field in YAML frontmatter"
        return 1
    fi

    if ! grep -q "^argument-hint:" ".claude/commands/dashboard.md"; then
        fail "Missing 'argument-hint' field in YAML frontmatter"
        return 1
    fi

    pass "YAML frontmatter is valid"
}

# Test 3: Validate required sections
test_required_sections() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 3: Validate required sections"

    local required_sections=(
        "## Overview"
        "## Pre-Execution Validation"
        "## Server Launch Phase"
        "## Expected Outcomes"
        "## Usage Examples"
        "## Troubleshooting"
    )

    local missing_sections=0

    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" ".claude/commands/dashboard.md"; then
            fail "Missing section: $section"
            missing_sections=$((missing_sections + 1))
        fi
    done

    if [ $missing_sections -eq 0 ]; then
        pass "All required sections present (${#required_sections[@]} sections)"
    else
        fail "$missing_sections sections missing"
        return 1
    fi
}

# Test 4: Validate allowed-tools syntax
test_allowed_tools() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 4: Validate allowed-tools declaration"

    local tools=$(grep "^allowed-tools:" ".claude/commands/dashboard.md" | cut -d':' -f2 | tr -d ' ')

    if [ -z "$tools" ]; then
        fail "allowed-tools field is empty"
        return 1
    fi

    # Check for expected tools
    if ! grep -q "allowed-tools:.*Bash" ".claude/commands/dashboard.md"; then
        fail "Bash tool not declared in allowed-tools"
        return 1
    fi

    pass "allowed-tools declared correctly: $tools"
}

# Test 5: Validate dashboard.py exists
test_dashboard_py_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 5: Validate dashboard.py exists"

    if [ -f "dashboard.py" ]; then
        pass "dashboard.py found"
    else
        fail "dashboard.py not found in project root"
        return 1
    fi
}

# Test 6: Validate dashboard.py has uv inline deps
test_dashboard_py_uv_deps() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 6: Validate dashboard.py has uv inline dependencies"

    if ! grep -q "# /// script" "dashboard.py"; then
        fail "Missing uv inline script header"
        return 1
    fi

    if ! grep -q "requires-python" "dashboard.py"; then
        fail "Missing requires-python declaration"
        return 1
    fi

    if ! grep -q "dependencies" "dashboard.py"; then
        fail "Missing dependencies declaration"
        return 1
    fi

    if ! grep -q "fastapi" "dashboard.py"; then
        fail "Missing fastapi dependency"
        return 1
    fi

    if ! grep -q "uvicorn" "dashboard.py"; then
        fail "Missing uvicorn dependency"
        return 1
    fi

    pass "dashboard.py has valid uv inline dependencies"
}

# Test 7: Validate static directory structure
test_static_directory() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 7: Validate static directory structure"

    if [ ! -d "static" ]; then
        fail "static/ directory not found"
        return 1
    fi

    local missing_files=0

    if [ ! -f "static/dashboard.html" ]; then
        fail "Missing static/dashboard.html"
        missing_files=$((missing_files + 1))
    fi

    if [ ! -f "static/dashboard.js" ]; then
        fail "Missing static/dashboard.js"
        missing_files=$((missing_files + 1))
    fi

    if [ ! -f "static/dashboard.css" ]; then
        fail "Missing static/dashboard.css"
        missing_files=$((missing_files + 1))
    fi

    if [ $missing_files -eq 0 ]; then
        pass "All static files present (3 files)"
    else
        fail "$missing_files static files missing"
        return 1
    fi
}

# Test 8: Validate HTML structure
test_html_structure() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 8: Validate dashboard.html structure"

    if ! grep -q "<!DOCTYPE html>" "static/dashboard.html"; then
        fail "Missing DOCTYPE declaration"
        return 1
    fi

    if ! grep -q "kanban-board" "static/dashboard.html"; then
        fail "Missing kanban-board element"
        return 1
    fi

    if ! grep -q "backlog-zone" "static/dashboard.html"; then
        fail "Missing backlog drop zone"
        return 1
    fi

    if ! grep -q "in-progress-zone" "static/dashboard.html"; then
        fail "Missing in-progress drop zone"
        return 1
    fi

    if ! grep -q "deployed-zone" "static/dashboard.html"; then
        fail "Missing deployed drop zone"
        return 1
    fi

    pass "HTML structure is valid"
}

# Test 9: Validate JavaScript API calls
test_javascript_api() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 9: Validate JavaScript API integration"

    if ! grep -q "/api/tasks" "static/dashboard.js"; then
        fail "Missing /api/tasks endpoint call"
        return 1
    fi

    if ! grep -q "/api/tasks/move" "static/dashboard.js"; then
        fail "Missing /api/tasks/move endpoint call"
        return 1
    fi

    if ! grep -q "handleDragStart" "static/dashboard.js"; then
        fail "Missing drag-and-drop handler: handleDragStart"
        return 1
    fi

    if ! grep -q "handleDrop" "static/dashboard.js"; then
        fail "Missing drag-and-drop handler: handleDrop"
        return 1
    fi

    pass "JavaScript API integration is valid"
}

# Test 10: Validate CSS theme
test_css_theme() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 10: Validate CSS factory theme"

    if ! grep -q "factory" "static/dashboard.css"; then
        fail "Missing factory theme elements"
        return 1
    fi

    if ! grep -q "kanban-column" "static/dashboard.css"; then
        fail "Missing kanban-column styles"
        return 1
    fi

    if ! grep -q "task-card" "static/dashboard.css"; then
        fail "Missing task-card styles"
        return 1
    fi

    if ! grep -q "dragging" "static/dashboard.css"; then
        fail "Missing drag-and-drop styles"
        return 1
    fi

    pass "CSS factory theme is valid"
}

# Test 11: Validate FastAPI endpoints
test_fastapi_endpoints() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 11: Validate FastAPI endpoint definitions"

    if ! grep -q "@app.get(\"/" "dashboard.py"; then
        fail "Missing root endpoint"
        return 1
    fi

    if ! grep -q "@app.get(\"/api/tasks" "dashboard.py"; then
        fail "Missing /api/tasks endpoint"
        return 1
    fi

    if ! grep -q "@app.post(\"/api/tasks/move" "dashboard.py"; then
        fail "Missing /api/tasks/move endpoint"
        return 1
    fi

    if ! grep -q "@app.get(\"/api/health" "dashboard.py"; then
        fail "Missing /api/health endpoint"
        return 1
    fi

    pass "All FastAPI endpoints defined"
}

# Test 12: Validate command argument parsing
test_argument_parsing() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 12: Validate command argument parsing"

    if ! grep -q -- "--port" ".claude/commands/dashboard.md"; then
        fail "Missing --port argument documentation"
        return 1
    fi

    if ! grep -q -- "--csv-path" ".claude/commands/dashboard.md"; then
        fail "Missing --csv-path argument documentation"
        return 1
    fi

    if ! grep -q -- "--open" ".claude/commands/dashboard.md"; then
        fail "Missing --open argument documentation"
        return 1
    fi

    pass "Command argument parsing documented"
}

# Test 13: Validate error handling
test_error_handling() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 13: Validate error handling in dashboard.py"

    if ! grep -q "try:" "dashboard.py"; then
        fail "No try-except blocks found"
        return 1
    fi

    if ! grep -q "HTTPException" "dashboard.py"; then
        fail "Missing HTTPException handling"
        return 1
    fi

    if ! grep -q "FileNotFoundError" "dashboard.py"; then
        fail "Missing FileNotFoundError handling"
        return 1
    fi

    pass "Error handling is implemented"
}

# Test 14: Functional test - uv installation check
test_uv_available() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 14: Check if uv is installed"

    if command -v uv &> /dev/null; then
        local UV_VERSION=$(uv --version 2>/dev/null || echo "unknown")
        pass "uv is installed: $UV_VERSION"
    else
        skip "uv not installed (optional for testing, required for running)"
    fi
}

# Test 15: Functional test - Python version check
test_python_version() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 15: Check Python version"

    if command -v python3 &> /dev/null; then
        local PY_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
        local PY_MAJOR=$(echo "$PY_VERSION" | cut -d'.' -f1)
        local PY_MINOR=$(echo "$PY_VERSION" | cut -d'.' -f2)

        if [ "$PY_MAJOR" -ge 3 ] && [ "$PY_MINOR" -ge 11 ]; then
            pass "Python version compatible: $PY_VERSION (>=3.11)"
        else
            fail "Python version incompatible: $PY_VERSION (requires >=3.11)"
            return 1
        fi
    else
        skip "Python 3 not found (required for running dashboard)"
    fi
}

# Test 16: Validate documentation completeness
test_documentation_completeness() {
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Test 16: Validate documentation completeness"

    local doc_sections=$(grep -c "^## " ".claude/commands/dashboard.md")

    if [ "$doc_sections" -lt 8 ]; then
        fail "Insufficient documentation sections (found: $doc_sections, expected: >=8)"
        return 1
    fi

    if ! grep -q "## Usage Examples" ".claude/commands/dashboard.md"; then
        fail "Missing Usage Examples section"
        return 1
    fi

    if ! grep -q "Example 1:" ".claude/commands/dashboard.md"; then
        fail "No usage examples provided"
        return 1
    fi

    pass "Documentation is comprehensive ($doc_sections sections)"
}

# Main test execution
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Test Suite: /dashboard Command"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Run all tests
    test_command_exists || true
    test_yaml_frontmatter || true
    test_required_sections || true
    test_allowed_tools || true
    test_dashboard_py_exists || true
    test_dashboard_py_uv_deps || true
    test_static_directory || true
    test_html_structure || true
    test_javascript_api || true
    test_css_theme || true
    test_fastapi_endpoints || true
    test_argument_parsing || true
    test_error_handling || true
    test_uv_available || true
    test_python_version || true
    test_documentation_completeness || true

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Test Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total tests run:    $TESTS_RUN"
    echo -e "Tests passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed:       ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        echo ""
        return 1
    fi
}

# Run tests
main
