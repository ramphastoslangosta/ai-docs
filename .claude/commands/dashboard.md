---
description: Launch interactive Kanban dashboard web server for drag-and-drop task management
allowed-tools: Bash, Read, Write
argument-hint: [--port PORT] [--csv-path PATH] [--open]
---

# Dashboard Command

Launch an interactive Kanban dashboard web server that reads tasks.csv and provides drag-and-drop task management with real-time CSV updates.

## Overview

The `/dashboard` command starts a FastAPI web server that serves an interactive Kanban board interface. Users can drag tasks between columns (Backlog, Planning, In Progress, Review, Deployed), and the server automatically updates tasks.csv with the new status. This follows the **agentic-drop-zones pattern** with live server architecture.

**Phase 1 Implementation**: Drag-and-drop task management with automatic CSV updates (NO command execution yet).

## Pre-Execution Validation

### Verify Environment

```bash
echo "🏭 Starting Dashboard Server..."
echo ""

# Parse arguments
PORT=8000
CSV_PATH=".claude/tasks.csv"
AUTO_OPEN=false

for arg in "$@"; do
    case "$arg" in
        --port=*) PORT="${arg#*=}" ;;
        --port) shift; PORT="$1" ;;
        --csv-path=*) CSV_PATH="${arg#*=}" ;;
        --csv-path) shift; CSV_PATH="$1" ;;
        --open) AUTO_OPEN=true ;;
    esac
done

echo "⚙️  Configuration:"
echo "   Port: $PORT"
echo "   CSV Path: $CSV_PATH"
echo "   Auto-open browser: $AUTO_OPEN"
echo ""
```

### Verify Tasks CSV

```bash
# Check if tasks.csv exists
if [ -f "$CSV_PATH" ]; then
    TASK_COUNT=$(tail -n +2 "$CSV_PATH" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Found tasks.csv: $CSV_PATH"
    echo "   Tasks: $TASK_COUNT"
elif [ -f "tasks.csv" ]; then
    CSV_PATH="tasks.csv"
    TASK_COUNT=$(tail -n +2 "$CSV_PATH" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Found tasks.csv: $CSV_PATH"
    echo "   Tasks: $TASK_COUNT"
elif [ -f ".claude/tasks.csv" ]; then
    CSV_PATH=".claude/tasks.csv"
    TASK_COUNT=$(tail -n +2 "$CSV_PATH" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Found tasks.csv: $CSV_PATH"
    echo "   Tasks: $TASK_COUNT"
else
    echo "❌ ERROR: tasks.csv not found"
    echo ""
    echo "Searched locations:"
    echo "  - $CSV_PATH"
    echo "  - tasks.csv"
    echo "  - .claude/tasks.csv"
    echo ""
    echo "Please create tasks.csv or specify path with --csv-path"
    exit 1
fi

echo ""
```

### Verify Dependencies

```bash
# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "❌ ERROR: uv not found"
    echo ""
    echo "uv is required to run the dashboard server."
    echo ""
    echo "Install uv:"
    echo "  macOS/Linux: curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  Or visit: https://github.com/astral-sh/uv"
    echo ""
    exit 1
fi

echo "✅ uv found: $(uv --version)"
```

### Verify Static Files

```bash
# Check if static directory and files exist
if [ ! -d "static" ]; then
    echo "⚠️  WARNING: static/ directory not found"
    echo "   Creating static/ directory..."
    mkdir -p static
fi

MISSING_FILES=0

if [ ! -f "static/dashboard.html" ]; then
    echo "❌ Missing: static/dashboard.html"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f "static/dashboard.js" ]; then
    echo "❌ Missing: static/dashboard.js"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f "static/dashboard.css" ]; then
    echo "❌ Missing: static/dashboard.css"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ $MISSING_FILES -gt 0 ]; then
    echo ""
    echo "❌ ERROR: $MISSING_FILES required files missing"
    echo ""
    echo "Required files:"
    echo "  - static/dashboard.html"
    echo "  - static/dashboard.js"
    echo "  - static/dashboard.css"
    echo ""
    echo "Please ensure all static files are present."
    exit 1
fi

echo "✅ All static files present"
```

### Check Port Availability

```bash
# Check if port is available
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  WARNING: Port $PORT is already in use"
    echo ""
    echo "To use a different port:"
    echo "  /dashboard --port 3000"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        exit 1
    fi
else
    echo "✅ Port $PORT available"
fi

echo ""
```

### Verify dashboard.py

```bash
# Check if dashboard.py exists
if [ ! -f "dashboard.py" ]; then
    echo "❌ ERROR: dashboard.py not found"
    echo ""
    echo "The dashboard server script is missing."
    echo "Please ensure dashboard.py is present in the project root."
    exit 1
fi

echo "✅ dashboard.py found"
echo ""
```

## Server Launch Phase

### Start FastAPI Server

```bash
echo "🚀 Launching dashboard server..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Dashboard Server Starting"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "   URL: http://localhost:$PORT"
echo "   CSV: $CSV_PATH"
echo ""
echo "   Press Ctrl+C to stop server"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Build uv run command
UV_CMD="uv run dashboard.py --port $PORT --csv-path $CSV_PATH"

if [ "$AUTO_OPEN" = true ]; then
    UV_CMD="$UV_CMD --open"
fi

# Launch server
$UV_CMD
```

## Dashboard Features

The dashboard provides the following functionality:

### Frontend (static/dashboard.html)

1. **5 Kanban Columns**:
   - Backlog (pending tasks)
   - Planning (planning phase)
   - In Progress (active work)
   - Review (code review/testing)
   - Deployed (completed tasks)

2. **Task Cards**:
   - Draggable cards with HTML5 Drag API
   - Color-coded by priority (critical, high, medium, low)
   - Display task ID, title, description, phase, effort
   - Visual feedback during drag operations

3. **Statistics Dashboard**:
   - Total task count
   - In-progress task count
   - Deployed task count
   - Column-specific task counts

4. **Factory Theme**:
   - Industrial design aesthetic
   - Animated factory icon
   - Gradient backgrounds
   - Smooth transitions and animations

### Backend (dashboard.py - FastAPI)

1. **API Endpoints**:
   - `GET /` - Serve dashboard HTML
   - `GET /api/tasks` - Return tasks from CSV as JSON
   - `POST /api/tasks/move` - Update task status in CSV
   - `GET /api/health` - Health check endpoint

2. **CSV Management**:
   - Reads tasks.csv on each request
   - Maps CSV status to Kanban columns
   - Updates CSV when tasks are moved
   - Preserves all task metadata

3. **Status Mapping**:
   ```
   CSV Status     → Kanban Column
   ────────────────────────────────
   pending        → backlog
   planning       → planning
   in-progress    → in-progress
   review         → review
   completed      → deployed
   blocked        → backlog
   archived       → deployed
   ```

## API Endpoint Details

### GET /api/tasks

Returns all tasks from tasks.csv as JSON array.

**Response**:
```json
{
  "tasks": [
    {
      "task_id": "TASK-20251029-001",
      "title": "Implement feature X",
      "description": "Add new feature",
      "priority": "high",
      "status": "in-progress",
      "phase": "development",
      "estimated_effort": "4h",
      "column": "in-progress"
    }
  ],
  "count": 1
}
```

### POST /api/tasks/move

Updates task status when moved between columns.

**Request Body**:
```json
{
  "task_id": "TASK-20251029-001",
  "old_status": "pending",
  "new_status": "in-progress"
}
```

**Response**:
```json
{
  "success": true,
  "task_id": "TASK-20251029-001",
  "new_status": "in-progress"
}
```

### GET /api/health

Health check endpoint.

**Response**:
```json
{
  "status": "healthy",
  "csv_path": ".claude/tasks.csv",
  "task_count": 15
}
```

## Expected Outcomes

After running `/dashboard`, you should have:

### Immediate Outcomes

1. **Server Started**: FastAPI server running on specified port (default: 8000)
2. **Dashboard Accessible**: Browser can access http://localhost:8000
3. **Tasks Loaded**: All tasks from CSV displayed in appropriate columns
4. **Interactive UI**: Tasks can be dragged between columns

### User Interactions

1. **Drag-and-Drop**:
   - User drags task card from one column to another
   - Visual feedback shows drag operation
   - Drop zones highlight when draggable enters

2. **Automatic Updates**:
   - On drop, POST request sent to `/api/tasks/move`
   - Server updates tasks.csv with new status
   - Dashboard refreshes to show updated state
   - Success toast notification displays

3. **Real-Time Data**:
   - Dashboard auto-refreshes every 30 seconds
   - Statistics update after each move
   - Column counts update dynamically

### File Structure

```
project-root/
├── dashboard.py              # FastAPI server (uv script)
├── static/
│   ├── dashboard.html        # Kanban board UI
│   ├── dashboard.js          # Drag-and-drop + API calls
│   └── dashboard.css         # Factory theme styling
└── .claude/
    └── tasks.csv             # Task data (updated by server)
```

## Usage Examples

### Example 1: Basic Usage

```bash
# Start dashboard on default port 8000
/dashboard

# Output:
# 🏭 Starting Dashboard Server...
#
# ⚙️  Configuration:
#    Port: 8000
#    CSV Path: .claude/tasks.csv
#    Auto-open browser: false
#
# ✅ Found tasks.csv: .claude/tasks.csv
#    Tasks: 15
#
# ✅ uv found: uv 0.4.0
# ✅ All static files present
# ✅ Port 8000 available
# ✅ dashboard.py found
#
# 🚀 Launching dashboard server...
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#    Dashboard Server Starting
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
#    URL: http://localhost:8000
#    CSV: .claude/tasks.csv
#
#    Press Ctrl+C to stop server
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# INFO:     Started server process [12345]
# INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Example 2: Custom Port

```bash
# Start on port 3000
/dashboard --port 3000

# Access at: http://localhost:3000
```

### Example 3: Custom CSV Path

```bash
# Use tasks.csv from custom location
/dashboard --csv-path /path/to/custom/tasks.csv
```

### Example 4: Auto-Open Browser

```bash
# Start server and automatically open browser
/dashboard --open

# Server starts and browser opens to http://localhost:8000
```

### Example 5: Combined Options

```bash
# Custom port, custom CSV, auto-open
/dashboard --port 3000 --csv-path /path/to/tasks.csv --open
```

### Example 6: Development Workflow

```bash
# Morning: Start dashboard
/dashboard --open

# Work session:
# - Drag tasks from Backlog → Planning
# - Drag tasks from Planning → In Progress
# - Drag tasks from In Progress → Review
# - Drag tasks from Review → Deployed

# tasks.csv automatically updated with each move
# Can verify with: grep ",completed," .claude/tasks.csv
```

### Example 7: Team Demo

```bash
# Start dashboard for team demonstration
/dashboard --port 8080 --open

# Share screen showing:
# - Current sprint progress
# - Tasks moving through pipeline
# - Real-time status updates
# - Factory-themed visual design
```

## Troubleshooting

### Port Already in Use

```bash
# Error: Port 8000 is already in use

# Solution 1: Use different port
/dashboard --port 3000

# Solution 2: Kill existing process
lsof -ti:8000 | xargs kill -9

# Solution 3: Find what's using the port
lsof -i :8000
```

### tasks.csv Not Found

```bash
# Error: tasks.csv not found

# Solution 1: Create tasks.csv
cat > .claude/tasks.csv << 'EOF'
task_id,title,description,priority,status,phase,estimated_effort,dependencies,branch_name,pr_template,test_file,notes
TASK-20251029-001,Sample Task,This is a sample task,medium,pending,planning,2h,,,,,
EOF

# Solution 2: Specify custom path
/dashboard --csv-path /path/to/tasks.csv

# Solution 3: Check if file exists elsewhere
find . -name "tasks.csv"
```

### uv Not Installed

```bash
# Error: uv not found

# Solution: Install uv
# macOS/Linux:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or visit: https://github.com/astral-sh/uv
```

### Static Files Missing

```bash
# Error: static/dashboard.html not found

# Solution 1: Verify files exist
ls -la static/

# Solution 2: Regenerate static files
# (Contact maintainer or check project repository)

# Solution 3: Ensure correct working directory
pwd
# Should be in project root where static/ exists
```

### Dashboard Not Loading

```bash
# Error: Dashboard shows blank page or errors

# Solution 1: Check browser console (F12)
# Look for JavaScript errors or failed network requests

# Solution 2: Verify server is running
curl http://localhost:8000/api/health

# Solution 3: Check file paths
ls static/dashboard.html static/dashboard.js static/dashboard.css

# Solution 4: Restart server
# Press Ctrl+C to stop, then run /dashboard again
```

### Task Move Fails

```bash
# Error: Task doesn't move or returns to original column

# Solution 1: Check server logs
# Look for errors in terminal where server is running

# Solution 2: Verify CSV permissions
ls -la .claude/tasks.csv
# Should be writable

# Solution 3: Check CSV format
head -n 5 .claude/tasks.csv
# Ensure headers match expected format

# Solution 4: Check browser network tab
# Look for failed POST requests to /api/tasks/move
```

### Browser Doesn't Auto-Open

```bash
# Error: --open flag doesn't open browser

# Solution 1: Open manually
open http://localhost:8000  # macOS
xdg-open http://localhost:8000  # Linux

# Solution 2: Check if open command exists
command -v open

# Solution 3: Copy URL and paste in browser
# http://localhost:8000
```

### CSV Updates Not Persisting

```bash
# Error: Task moves work but CSV doesn't save

# Solution 1: Check file permissions
chmod u+w .claude/tasks.csv

# Solution 2: Verify disk space
df -h .

# Solution 3: Check for file locks
lsof | grep tasks.csv

# Solution 4: Review server error logs
# Check terminal output for write errors
```

## Integration with Other Commands

### After Code Review

```bash
# 1. Generate tasks from code review
/code-review full
/generate_tasks

# 2. Launch dashboard to manage tasks
/dashboard --open

# 3. Drag tasks through workflow
# Visual task management instead of manual CSV editing
```

### During Sprint Planning

```bash
# 1. Plan sprint tasks
/plan-sprint 2w

# 2. Launch dashboard
/dashboard --open

# 3. Organize tasks by dragging:
# - High priority → Planning column
# - Ready to start → In Progress
# - Review dependencies
```

### Daily Standup

```bash
# Launch dashboard for standup meeting
/dashboard --port 8080 --open

# Share screen:
# - Show In Progress column (what you're working on)
# - Show Review column (what needs review)
# - Show Deployed column (what was completed)
# - Drag new tasks into In Progress
```

### Task Execution Workflow

```bash
# Terminal 1: Keep dashboard running
/dashboard --open

# Terminal 2: Execute tasks
/execute-task TASK-20251029-001

# Dashboard shows real-time status:
# - Task moves from Planning → In Progress (automatically)
# - On completion, move to Review
# - After review, move to Deployed
```

### End-of-Sprint Review

```bash
# 1. Launch dashboard
/dashboard --open

# 2. Review sprint progress
# - Count tasks in Deployed column
# - Check blocked tasks in Backlog
# - Review In Progress tasks

# 3. Generate sprint report
/sprint-dashboard

# 4. Compare visual dashboard with HTML report
```

## Advanced Usage

### Keyboard Shortcuts (Future Enhancement)

```
Note: Phase 1 uses mouse drag-and-drop only.
Phase 2 will add keyboard navigation:
- Arrow keys to navigate tasks
- Space to select/deselect
- Enter to move to next column
- Numbers (1-5) to move to specific column
```

### Filtering Tasks (Future Enhancement)

```
Note: Phase 1 shows all tasks.
Phase 2 will add filtering:
- Filter by priority
- Filter by phase
- Search by task ID or title
- Hide completed tasks
```

### Multi-Select Drag (Future Enhancement)

```
Note: Phase 1 allows dragging one task at a time.
Phase 2 will support:
- Shift+Click to select multiple
- Drag multiple tasks together
- Bulk status updates
```

## Best Practices

1. **Keep Dashboard Running**: Start dashboard at beginning of work session and keep it open
2. **Verify CSV Backup**: Keep backup of tasks.csv before major reorganizations
3. **Use Consistent Port**: Choose one port and stick with it to avoid conflicts
4. **Close Other Servers**: Ensure no other servers are using the same port
5. **Auto-Open for Demos**: Use `--open` flag when presenting to team
6. **Monitor Server Logs**: Watch terminal output for errors and warnings
7. **Refresh on Errors**: If UI gets out of sync, refresh browser page (F5)
8. **Test Before Sharing**: Move a few tasks locally before sharing screen

## Success Criteria

A successful dashboard launch includes:
- ✅ Server starts without errors
- ✅ Dashboard loads in browser
- ✅ All tasks displayed in correct columns
- ✅ Task cards show all metadata (ID, title, priority, etc.)
- ✅ Drag-and-drop works smoothly
- ✅ Tasks move between columns
- ✅ CSV updates automatically
- ✅ Statistics update in real-time
- ✅ No console errors in browser
- ✅ Server responds to API requests

## Phase 2 Preview (Future)

Phase 2 will add command execution capabilities:

- **Right-click context menu** on tasks
- **Execute atomic plan** directly from dashboard
- **Run test checkpoints** with visual feedback
- **Commit changes** from UI
- **WebSocket** for real-time updates across multiple browsers
- **Task dependencies** visualization
- **Timeline view** with Gantt chart
- **Batch operations** on multiple tasks

---

**Note**: This is Phase 1 implementation focused on drag-and-drop task management with automatic CSV updates. Command execution features will be added in Phase 2.
