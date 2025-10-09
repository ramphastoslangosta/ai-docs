#!/bin/bash
# Input Validation Library for AI-Docs Task Management System
# Prevents command injection (CWE-78) and path traversal attacks
# Created: 2025-10-08
# Task: TASK-20251008-003

set -euo pipefail

# Global constants
readonly TASK_ID_PATTERN='^(TASK|ARCH|HOTFIX|DEVOPS|MTENANT|PROCESS)-[0-9]{8}-[0-9]{3}$'
readonly WORKSPACE_ROOT="${WORKSPACE_ROOT:-.claude/workspace}"
