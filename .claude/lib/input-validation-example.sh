#!/bin/bash
# Example Usage: Input Validation Library
# Demonstrates proper integration of input-validation.sh
# Task: TASK-20251008-003

set -euo pipefail

# Source the validation library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/input-validation.sh"

echo "=========================================="
echo "Input Validation Library - Usage Examples"
echo "=========================================="
echo ""

# Example 1: Validate TASK_ID
echo "Example 1: Validating TASK_ID"
echo "------------------------------"
TASK_ID="TASK-20251008-003"
if validate_task_id "$TASK_ID"; then
    echo "✅ TASK_ID '$TASK_ID' is valid"
else
    echo "❌ TASK_ID '$TASK_ID' is invalid"
    exit 1
fi
echo ""

# Example 2: Reject malicious TASK_ID
echo "Example 2: Rejecting malicious input"
echo "-------------------------------------"
MALICIOUS_ID="TASK-001; rm -rf /"
if validate_task_id "$MALICIOUS_ID" 2>/dev/null; then
    echo "❌ DANGER: Malicious ID was accepted!"
    exit 1
else
    echo "✅ Malicious ID correctly rejected"
fi
echo ""

# Example 3: Sanitize path
echo "Example 3: Sanitizing paths"
echo "---------------------------"
SAFE_PATH="workspace/TASK-20251008-003"
if canonical=$(sanitize_path "$SAFE_PATH" "."); then
    echo "✅ Safe path accepted: $canonical"
else
    echo "❌ Safe path rejected"
    exit 1
fi
echo ""

# Example 4: Block path traversal
echo "Example 4: Blocking path traversal"
echo "-----------------------------------"
ATTACK_PATH="../../../etc/passwd"
if sanitize_path "$ATTACK_PATH" "." 2>/dev/null; then
    echo "❌ DANGER: Path traversal was accepted!"
    exit 1
else
    echo "✅ Path traversal correctly blocked"
fi
echo ""

# Example 5: Validate workspace directory
echo "Example 5: Validating workspace"
echo "--------------------------------"
if workspace=$(validate_workspace_dir "$TASK_ID"); then
    echo "✅ Workspace path: $workspace"
else
    echo "❌ Workspace validation failed"
    exit 1
fi
echo ""

# Example 6: Validate file readability
echo "Example 6: Validating file access"
echo "----------------------------------"
TEST_FILE="tasks.csv"
if validate_file_readable "$TEST_FILE"; then
    echo "✅ File '$TEST_FILE' is readable"
else
    echo "❌ File '$TEST_FILE' is not readable"
    exit 1
fi
echo ""

echo "=========================================="
echo "All examples completed successfully!"
echo "=========================================="
echo ""
echo "Integration Pattern:"
echo "  1. Source the library: source .claude/lib/input-validation.sh"
echo "  2. Validate all user input before using in commands"
echo "  3. Never use unvalidated input in eval, system(), or shell commands"
echo "  4. Check return codes: validation failures return 1"
echo ""
