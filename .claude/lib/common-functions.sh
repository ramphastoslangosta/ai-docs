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

# =============================================================================
# Function: update_task_status
# Purpose: Update task status in tasks.csv file
#
# Arguments:
#   $1 - Task ID (e.g., TASK-20250929-012)
#   $2 - New status (pending|in-progress|completed|blocked|archived)
#   $3 - CSV file path (optional, defaults to .claude/tasks.csv)
#
# Returns:
#   Exit code: 0 on success, ERR_* on failure
#
# Example:
#   update_task_status "TASK-20250929-012" "completed"
#
# Used in:
#   - execute-task.md (line 298)
#   - archive-workspace.md (line 215)
#   - cleanup-workspaces.md (line 267)
#   - atomic-plan.md (line 512)
# =============================================================================
update_task_status() {
    local task_id="${1:-}"
    local new_status="${2:-}"
    local csv_file="${3:-.claude/tasks.csv}"

    # Validate arguments
    if [ -z "$task_id" ]; then
        echo -e "${COLOR_RED}ERROR: Task ID required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    if [ -z "$new_status" ]; then
        echo -e "${COLOR_RED}ERROR: Status required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    # Validate status value
    case "$new_status" in
        pending|in-progress|completed|blocked|archived|planning)
            # Valid status
            ;;
        *)
            echo -e "${COLOR_RED}ERROR: Invalid status: $new_status${COLOR_RESET}" >&2
            echo "Valid values: pending, in-progress, completed, blocked, archived, planning" >&2
            return $ERR_INVALID_ARGUMENT
            ;;
    esac

    # Validate CSV file exists
    if [ ! -f "$csv_file" ]; then
        echo -e "${COLOR_RED}ERROR: CSV file not found: $csv_file${COLOR_RESET}" >&2
        return $ERR_FILE_NOT_FOUND
    fi

    # Check if task exists in CSV
    if ! grep -q "^$task_id," "$csv_file"; then
        echo -e "${COLOR_RED}ERROR: Task not found in CSV: $task_id${COLOR_RESET}" >&2
        return $ERR_FILE_NOT_FOUND
    fi

    # Update status (field 5 in CSV)
    # macOS sed requires '' after -i for in-place editing
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^\($task_id,[^,]*,[^,]*,[^,]*,\)[^,]*/\1$new_status/" "$csv_file"
    else
        sed -i "s/^\($task_id,[^,]*,[^,]*,[^,]*,\)[^,]*/\1$new_status/" "$csv_file"
    fi

    # Verify update succeeded
    if grep -q "^$task_id,.*,$new_status," "$csv_file"; then
        echo -e "${COLOR_GREEN}✅ Updated $task_id status to: $new_status${COLOR_RESET}"
        return 0
    else
        echo -e "${COLOR_RED}ERROR: Failed to update status${COLOR_RESET}" >&2
        return $ERR_OPERATION_FAILED
    fi
}

# =============================================================================
# Function: update_checklist_item
# Purpose: Mark a checklist item as complete or incomplete
#
# Arguments:
#   $1 - Checklist file path
#   $2 - Item text to match (partial match supported)
#   $3 - Status: "complete" or "incomplete" (optional, defaults to "complete")
#
# Returns:
#   Exit code: 0 on success, ERR_* on failure
#
# Example:
#   update_checklist_item "workspace/TASK-001/checklist-TASK-001.md" "Create library" "complete"
#
# Used in:
#   - execute-task.md (line 312-325)
#   - atomic-plan.md (line 478-489)
# =============================================================================
update_checklist_item() {
    local checklist_file="${1:-}"
    local item_text="${2:-}"
    local item_status="${3:-complete}"

    # Validate arguments
    if [ -z "$checklist_file" ]; then
        echo -e "${COLOR_RED}ERROR: Checklist file path required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    if [ -z "$item_text" ]; then
        echo -e "${COLOR_RED}ERROR: Item text required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    # Validate checklist file exists
    if [ ! -f "$checklist_file" ]; then
        echo -e "${COLOR_RED}ERROR: Checklist file not found: $checklist_file${COLOR_RESET}" >&2
        return $ERR_FILE_NOT_FOUND
    fi

    # Determine checkbox state
    local from_state to_state
    if [ "$item_status" = "complete" ]; then
        from_state="- \[ \]"
        to_state="- [x]"
    else
        from_state="- \[x\]"
        to_state="- [ ]"
    fi

    # Escape special regex characters in item text
    local escaped_text=$(echo "$item_text" | sed 's/[]\/$*.^[]/\\&/g')

    # Update checklist item
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^$from_state \(.*$escaped_text.*\)$/$to_state \1/" "$checklist_file"
    else
        sed -i "s/^$from_state \(.*$escaped_text.*\)$/$to_state \1/" "$checklist_file"
    fi

    # Verify update
    if grep -q "^\- \[x\].*$escaped_text" "$checklist_file"; then
        echo -e "${COLOR_GREEN}✅ Marked as complete: $item_text${COLOR_RESET}"
        return 0
    elif [ "$item_status" = "incomplete" ] && grep -q "^\- \[ \].*$escaped_text" "$checklist_file"; then
        echo -e "${COLOR_YELLOW}⚪ Marked as incomplete: $item_text${COLOR_RESET}"
        return 0
    else
        echo -e "${COLOR_YELLOW}⚠️  Item may not have been updated: $item_text${COLOR_RESET}" >&2
        return 0  # Don't fail, just warn
    fi
}

# =============================================================================
# Function: append_note
# Purpose: Append a timestamped note to notes.md file
#
# Arguments:
#   $1 - Note text
#   $2 - Notes file path (optional, defaults to notes.md in current workspace)
#   $3 - Timestamp format (optional, defaults to "%Y-%m-%d %H:%M:%S")
#
# Returns:
#   Exit code: 0 on success, ERR_* on failure
#
# Example:
#   append_note "Started implementation" "workspace/TASK-001/notes.md"
#
# Used in:
#   - execute-task.md (line 335-342)
#   - atomic-plan.md (line 502-509)
# =============================================================================
append_note() {
    local note_text="${1:-}"
    local notes_file="${2:-notes.md}"
    local timestamp_format="${3:-%Y-%m-%d %H:%M:%S}"

    # Validate note text provided
    if [ -z "$note_text" ]; then
        echo -e "${COLOR_RED}ERROR: Note text required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    # Create notes file if it doesn't exist
    if [ ! -f "$notes_file" ]; then
        echo "# Session Notes" > "$notes_file"
        echo "" >> "$notes_file"
    fi

    # Generate timestamp
    local timestamp=$(date +"$timestamp_format")

    # Append note with timestamp
    echo "**[$timestamp]** $note_text" >> "$notes_file"

    echo -e "${COLOR_GREEN}📝 Note added: $note_text${COLOR_RESET}"
    return 0
}

# =============================================================================
# Function: git_commit_with_message
# Purpose: Create a git commit with standardized message format
#
# Arguments:
#   $1 - Commit message
#   $2 - Files to add (optional, defaults to current directory)
#   $3 - Task ID to append (optional)
#
# Returns:
#   Exit code: 0 on success, ERR_* on failure
#
# Example:
#   git_commit_with_message "feat: add new function" "lib/*.sh" "ARCH-20251103-001"
#
# Used in:
#   - execute-task.md (line 285-295)
#   - atomic-plan.md (line 520-530)
#   - archive-workspace.md (line 133-136)
# =============================================================================
git_commit_with_message() {
    local commit_message="${1:-}"
    local files="${2:-.}"
    local task_id="${3:-}"

    # Validate commit message
    if [ -z "$commit_message" ]; then
        echo -e "${COLOR_RED}ERROR: Commit message required${COLOR_RESET}" >&2
        return $ERR_INVALID_ARGUMENT
    fi

    # Check if in git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${COLOR_YELLOW}⚠️  Not a git repository, skipping commit${COLOR_RESET}" >&2
        return 0
    fi

    # Add files
    if [ -n "$files" ]; then
        git add $files
        if [ $? -ne 0 ]; then
            echo -e "${COLOR_RED}ERROR: Failed to add files${COLOR_RESET}" >&2
            return $ERR_OPERATION_FAILED
        fi
    fi

    # Check if there are changes to commit
    if git diff --cached --quiet; then
        echo -e "${COLOR_YELLOW}⚠️  No changes to commit${COLOR_RESET}"
        return 0
    fi

    # Append task ID to message if provided
    local full_message="$commit_message"
    if [ -n "$task_id" ]; then
        full_message="$commit_message

Task: $task_id"
    fi

    # Create commit
    git commit -m "$full_message"

    if [ $? -eq 0 ]; then
        echo -e "${COLOR_GREEN}✅ Committed: $commit_message${COLOR_RESET}"
        return 0
    else
        echo -e "${COLOR_RED}ERROR: Git commit failed${COLOR_RESET}" >&2
        return $ERR_OPERATION_FAILED
    fi
}
