#!/bin/bash
# Common Functions Library
# Purpose: Reusable bash functions for Claude Code workspace operations
# Task: ARCH-20251103-001
# Created: 2025-11-03
#
# This library provides standardized implementations for:
# - Workspace progress tracking
# - Task status management
# - Checklist item updates
# - Note appending with timestamps
# - Git commit automation
# - Duration formatting
#
# Usage:
#   source "$(dirname "$0")/../lib/common-functions.sh"
#
# Requirements:
#   - Bash 4.0+
#   - Git (for git_commit_with_message)
#   - Standard Unix tools (grep, sed, awk, date)
#
# Security:
#   - All functions validate input parameters
#   - Path traversal prevention
#   - Safe file operations with error checking

set -euo pipefail

# Library version
readonly COMMON_FUNCTIONS_VERSION="1.0.0"

# Color codes for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'

# Error codes
readonly ERR_INVALID_ARGUMENT=1
readonly ERR_FILE_NOT_FOUND=2
readonly ERR_OPERATION_FAILED=3

# =============================================================================
# Function: get_workspace_progress
# Purpose: Calculate workspace completion percentage from checklist
#
# Arguments:
#   $1 - Task ID (e.g., TASK-20250929-012)
#   $2 - Workspace directory path (optional, defaults to workspace/$TASK_ID)
#
# Returns:
#   Prints: "COMPLETED/TOTAL (PERCENTAGE%)"
#   Exit code: 0 on success, ERR_* on failure
#
# Example:
#   get_workspace_progress "TASK-20250929-012"
#   # Output: "15/20 (75%)"
#
# Used in:
#   - list-workspaces.md (line 62-74)
#   - archive-workspace.md (line 86-95)
#   - cleanup-workspaces.md (line 121-130)
#   - atomic-plan.md (line 445-456)
# =============================================================================
get_workspace_progress() {
    local task_id="${1:-}"
    local workspace_dir="${2:-workspace/$task_id}"

    # Validate task ID provided
    if [ -z "$task_id" ]; then
        echo -e "${COLOR_RED}ERROR: Task ID required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    # Validate workspace exists
    if [ ! -d "$workspace_dir" ]; then
        echo -e "${COLOR_RED}ERROR: Workspace not found: $workspace_dir${COLOR_RESET}" >&2
        return $ERR_FILE_NOT_FOUND
    fi

    local checklist_file="$workspace_dir/checklist-$task_id.md"

    # Check if checklist exists
    if [ ! -f "$checklist_file" ]; then
        echo "0/0 (0%)"
        return 0
    fi

    # Count total and completed items
    local total_items=$(grep -cE "\[ \]|\[x\]" "$checklist_file" 2>/dev/null || echo "0")
    local completed_items=$(grep -c "\[x\]" "$checklist_file" 2>/dev/null || echo "0")

    # Calculate percentage
    local progress_pct=0
    if [ "$total_items" -gt 0 ]; then
        progress_pct=$(( completed_items * 100 / total_items ))
    fi

    # Output formatted result
    echo "$completed_items/$total_items ($progress_pct%)"
    return 0
}
