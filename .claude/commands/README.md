# Claude Code Commands

This directory contains slash command definitions for the Claude Code system.

## Available Commands

### /dashboard

**Description**: Launch interactive Kanban dashboard web server for drag-and-drop task management

**Usage**: `/dashboard [--port PORT] [--csv-path PATH] [--open]`

**Tools**: Bash, Read, Write

**Complexity**: Complex

**Created**: 2025-10-30

**Example**:
```bash
# Start dashboard on default port 8000
/dashboard

# Start on custom port and auto-open browser
/dashboard --port 3000 --open

# Use custom CSV path
/dashboard --csv-path /path/to/tasks.csv
```

**Key Features**:
- Interactive Kanban board with 5 columns (Backlog → Planning → In Progress → Review → Deployed)
- Drag-and-drop task management with automatic CSV updates
- Factory-themed visual design with animations
- Real-time statistics dashboard
- FastAPI backend with uv inline dependencies
- RESTful API endpoints for task operations
- Auto-refresh every 30 seconds
- Phase 1: Task management only (command execution in Phase 2)

**API Endpoints**:
- `GET /` - Serve dashboard HTML
- `GET /api/tasks` - Get all tasks as JSON
- `POST /api/tasks/move` - Update task status
- `GET /api/health` - Health check

**Related Commands**: /sprint-dashboard, /plan-sprint, /execute-task

---

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
