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
