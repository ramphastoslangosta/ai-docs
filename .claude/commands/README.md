# Claude Code Commands

This directory contains slash command definitions for the Claude Code system.

## Available Commands

### /plan-sprint

**Description**: Plan development sprints by analyzing tasks.csv and grouping work into time-boxed iterations with effort estimates and timelines

**Usage**: `/plan-sprint [sprint-duration] [--priority LEVEL] [--start-date DATE]`

**Tools**: Read, Write, Bash, Glob

**Complexity**: Medium

**Created**: 2025-10-30

**Example**:
```bash
# Plan default 2-week sprint
/plan-sprint

# Plan 1-week sprint with critical tasks only
/plan-sprint 1w --priority critical

# Plan future sprint
/plan-sprint 2w --start-date 2025-11-04
```

**Related Commands**: /generate_tasks, /atomic-plan, /execute-task

---

### /session-report

**Description**: Generate an HTML dashboard with infographic summary of the current session

**Usage**: `/session-report [output-path] [--format html|json] [--include-git]`

**Tools**: Read, Write, Bash, Glob, Grep

**Complexity**: Medium

**Created**: 2025-10-29

**Example**:
```bash
/session-report <arguments>
```

---

### /sprint-dashboard

**Description**: Generate a dynamic, interactive HTML dashboard for sprint visualization with a "factory view" metaphor showing tasks flowing through development stages

**Usage**: `/sprint-dashboard [sprint-date] [--auto-refresh N] [--theme THEME] [--open]`

**Tools**: Read, Write, Bash, Glob

**Complexity**: Medium

**Created**: 2025-10-30

**Example**:
```bash
# Generate dashboard for latest sprint
/sprint-dashboard

# Generate with custom refresh rate and open in browser
/sprint-dashboard --auto-refresh 15 --open

# Generate for specific sprint with factory theme
/sprint-dashboard 2025-10-30 --theme factory --open
```

**Key Features**:
- Factory-themed visual design with conveyor belt animations
- 5 development stations: Backlog → In Progress → Testing → Review → Complete
- Real-time task cards with priority badges and progress indicators
- Interactive filtering by priority, phase, and search
- Auto-refresh capability (default: 30s)
- Task detail modal on click
- Responsive mobile-friendly design
- Sprint metrics panel with completion rate and velocity

**Related Commands**: /plan-sprint, /execute-task, /session-report

---
