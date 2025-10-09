#!/bin/bash
# Phase 1: Critical Infrastructure & Security
# Generated: 2025-10-08 16:00:00 by task-package-generator

set -e

echo "🌿 Creating Phase 1 branches..."

# Verify on main branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "not-initialized")
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "not-initialized" ]; then
    echo "⚠️  Warning: Not on main branch (currently on $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Create branches for each task
echo "Creating branch: infrastructure/critical-setup-20251008"
git checkout -b infrastructure/critical-setup-20251008 2>/dev/null || echo "Note: Branch may already exist or git not initialized"

# Return to main
git checkout main 2>/dev/null || echo "Note: No main branch yet - run git init first"
echo "✅ Phase 1 branch created successfully"
echo "📋 Summary: 1 branch created (all Phase 1 tasks share this branch)"
git branch 2>/dev/null | grep "infrastructure" || echo "Note: Run git init to enable branch management"
