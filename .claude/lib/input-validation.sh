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

# Sanitize path to prevent directory traversal
# Arguments:
#   $1 - path: Path to sanitize
#   $2 - base_dir: Base directory (default: current directory)
# Returns:
#   0 and prints canonical path if safe, 1 if dangerous
# Example:
#   canonical_path=$(sanitize_path "workspace/TASK-001" ".")
sanitize_path() {
    local path="$1"
    local base_dir="${2:-.}"

    # Reject paths containing ..
    if [[ "$path" == *".."* ]]; then
        echo "❌ ERROR: Path contains directory traversal (..) - rejected for security" >&2
        return 1
    fi

    # Reject absolute paths (unless base_dir is also absolute and matching)
    if [[ "$path" == /* ]]; then
        echo "❌ ERROR: Absolute paths not allowed - rejected for security" >&2
        return 1
    fi

    # Canonicalize path (macOS compatible)
    local canonical_path
    local canonical_base

    # Get canonical base directory first
    if ! canonical_base=$(cd "$base_dir" 2>/dev/null && pwd); then
        echo "❌ ERROR: Cannot access base directory: $base_dir" >&2
        return 1
    fi

    # Combine paths
    local combined_path="$canonical_base/$path"

    # Canonicalize if exists, otherwise construct manually
    if [ -e "$combined_path" ]; then
        canonical_path=$(realpath "$combined_path" 2>/dev/null || echo "$combined_path")
    else
        # For non-existent paths, construct canonical path manually
        canonical_path="$combined_path"
    fi

    # Verify path is within base directory
    if [[ "$canonical_path" != "$canonical_base"* ]]; then
        echo "❌ ERROR: Path escapes base directory - rejected for security" >&2
        echo "  Attempted: $canonical_path" >&2
        echo "  Allowed base: $canonical_base" >&2
        return 1
    fi

    echo "$canonical_path"
    return 0
}
