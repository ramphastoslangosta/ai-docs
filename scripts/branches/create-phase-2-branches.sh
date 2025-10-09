#!/bin/bash
# Phase 2: Operational Hardening
# Generated: 2025-10-08 16:00:00 by task-package-generator

set -e

echo "🌿 Creating Phase 2 branches..."

# Verify on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Warning: Not on main branch (currently on $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Create branches for each task
echo "Creating branch: operations/workspace-management-20251008"
git checkout -b operations/workspace-management-20251008

# Return to main
git checkout main
echo "✅ Phase 2 branch created successfully"
echo "📋 Summary: 1 branch created (all Phase 2 tasks share this branch)"
git branch | grep "operations"
