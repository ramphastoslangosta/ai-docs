#!/bin/bash
# Input Validation Library for AI-Docs Task Management System
# Prevents command injection (CWE-78) and path traversal attacks
# Created: 2025-10-08
# Task: TASK-20251008-003

set -euo pipefail

# Global constants
readonly TASK_ID_PATTERN='^(TASK|ARCH|HOTFIX|DEVOPS|MTENANT|PROCESS)-[0-9]{8}-[0-9]{3}$'
readonly WORKSPACE_ROOT="${WORKSPACE_ROOT:-.claude/workspace}"

# Validate TASK_ID format
# Arguments:
#   $1 - task_id: String to validate (e.g., "TASK-20251008-003")
# Returns:
#   0 if valid, 1 if invalid
# Example:
#   validate_task_id "TASK-20251008-001" && echo "Valid"
validate_task_id() {
    local task_id="$1"

    if [[ -z "$task_id" ]]; then
        echo "❌ ERROR: TASK_ID is empty" >&2
        return 1
    fi

    if [[ ! "$task_id" =~ $TASK_ID_PATTERN ]]; then
        echo "❌ ERROR: Invalid TASK_ID format: $task_id" >&2
        echo "Expected format: PREFIX-YYYYMMDD-NNN" >&2
        echo "Valid prefixes: TASK, ARCH, HOTFIX, DEVOPS, MTENANT, PROCESS" >&2
        echo "Example: TASK-20251008-001" >&2
        return 1
    fi

    return 0
}
