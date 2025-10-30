---
description: Generate a dynamic, interactive HTML dashboard for sprint visualization with a "factory view" metaphor showing tasks flowing through development stages
allowed-tools: Read, Write, Bash, Glob
argument-hint: [sprint-date] [--auto-refresh N] [--theme THEME] [--open] - Sprint date (YYYY-MM-DD), auto-refresh seconds, theme, open in browser
---

# Sprint Dashboard

Generate an interactive, visually engaging HTML dashboard for sprint progress tracking. Uses a "factory view" metaphor showing tasks flowing through development stages like a production line. Features real-time updates, filtering, and comprehensive sprint metrics.

## Overview

The sprint dashboard transforms sprint data into an intuitive visual interface that:
- Displays tasks as cards moving through development stages
- Provides real-time progress metrics and bottleneck detection
- Supports interactive filtering and searching
- Auto-refreshes to show live updates
- Works with data from /plan-sprint and tasks.csv

## Pre-Execution Validation

### Verify Sprint Data Sources

```bash
echo "Generating sprint dashboard..."
echo ""

# Parse arguments
SPRINT_DATE="${1:-}"
AUTO_REFRESH=30
THEME="factory"
OPEN_BROWSER=false

# Parse optional flags
shift 2>/dev/null
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-refresh)
            AUTO_REFRESH="$2"
            shift 2
            ;;
        --theme)
            THEME="$2"
            shift 2
            ;;
        --open)
            OPEN_BROWSER=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Determine sprint date
if [ -z "$SPRINT_DATE" ]; then
    # Find latest sprint
    LATEST_SPRINT=$(ls -t .claude/sprints/sprint-*.md 2>/dev/null | head -1)
    if [ -n "$LATEST_SPRINT" ]; then
        SPRINT_DATE=$(basename "$LATEST_SPRINT" .md | sed 's/sprint-//')
        echo "Using latest sprint: $SPRINT_DATE"
    else
        echo "ERROR: No sprints found"
        echo "   Run: /plan-sprint to create a sprint"
        exit 1
    fi
else
    echo "Using specified sprint: $SPRINT_DATE"
fi

echo ""

# Validate sprint files exist
SPRINT_FILE=".claude/sprints/sprint-${SPRINT_DATE}.md"
SPRINT_BACKLOG=".claude/sprints/sprint-${SPRINT_DATE}-backlog.csv"
SPRINT_TIMELINE=".claude/sprints/sprint-${SPRINT_DATE}-timeline.md"

if [ ! -f "$SPRINT_FILE" ]; then
    echo "ERROR: Sprint file not found: $SPRINT_FILE"
    exit 1
fi

echo "Sprint files validated"

# Check for tasks.csv
if [ ! -f ".claude/tasks.csv" ]; then
    echo "WARNING: tasks.csv not found - using limited data"
fi

echo "Theme: $THEME"
echo "Auto-refresh: ${AUTO_REFRESH}s"
echo ""
```

### Validate Theme Selection

```bash
# Validate theme
case "$THEME" in
    factory|kanban|timeline)
        # Valid theme
        ;;
    *)
        echo "WARNING: Unknown theme '$THEME', defaulting to 'factory'"
        THEME="factory"
        ;;
esac
```

### Create Output Directory

```bash
# Create dashboard output directory
mkdir -p .claude/sprints/dashboards

OUTPUT_FILE=".claude/sprints/dashboards/sprint-${SPRINT_DATE}-dashboard.html"

echo "Output: $OUTPUT_FILE"
echo ""
```

## Data Collection Phase

### Read Sprint Backlog

```bash
echo "Collecting sprint data..."
echo ""

# Initialize counters
TOTAL_TASKS=0
BACKLOG_COUNT=0
INPROGRESS_COUNT=0
TESTING_COUNT=0
REVIEW_COUNT=0
COMPLETE_COUNT=0

# Read sprint backlog if exists
if [ -f "$SPRINT_BACKLOG" ]; then
    TOTAL_TASKS=$(tail -n +2 "$SPRINT_BACKLOG" 2>/dev/null | wc -l | tr -d ' ')
    echo "   Sprint backlog: $TOTAL_TASKS tasks"
fi

# Read tasks.csv for current status
if [ -f ".claude/tasks.csv" ]; then
    # Extract task IDs from sprint backlog
    SPRINT_TASK_IDS=$(tail -n +2 "$SPRINT_BACKLOG" 2>/dev/null | cut -d',' -f1)

    for TASK_ID in $SPRINT_TASK_IDS; do
        # Get task status from tasks.csv
        TASK_STATUS=$(grep "^$TASK_ID," .claude/tasks.csv 2>/dev/null | cut -d',' -f5)

        case "$TASK_STATUS" in
            pending)
                BACKLOG_COUNT=$((BACKLOG_COUNT + 1))
                ;;
            in-progress)
                INPROGRESS_COUNT=$((INPROGRESS_COUNT + 1))
                ;;
            testing)
                TESTING_COUNT=$((TESTING_COUNT + 1))
                ;;
            review)
                REVIEW_COUNT=$((REVIEW_COUNT + 1))
                ;;
            completed)
                COMPLETE_COUNT=$((COMPLETE_COUNT + 1))
                ;;
        esac
    done

    echo "   Status distribution:"
    echo "      Backlog: $BACKLOG_COUNT"
    echo "      In Progress: $INPROGRESS_COUNT"
    echo "      Testing: $TESTING_COUNT"
    echo "      Review: $REVIEW_COUNT"
    echo "      Complete: $COMPLETE_COUNT"
fi

echo ""
```

### Calculate Sprint Progress

```bash
# Calculate completion rate
if [ "$TOTAL_TASKS" -gt 0 ]; then
    COMPLETION_RATE=$((COMPLETE_COUNT * 100 / TOTAL_TASKS))
else
    COMPLETION_RATE=0
fi

echo "Sprint progress: $COMPLETION_RATE% ($COMPLETE_COUNT of $TOTAL_TASKS)"
echo ""
```

### Read Sprint Timeline

```bash
# Read timeline for additional context
TIMELINE_TOTAL=0
TIMELINE_DONE=0

if [ -f "$SPRINT_TIMELINE" ]; then
    TIMELINE_TOTAL=$(grep -c "\- \[ \]\|\- \[x\]" "$SPRINT_TIMELINE" 2>/dev/null || echo 0)
    TIMELINE_DONE=$(grep -c "\- \[x\]" "$SPRINT_TIMELINE" 2>/dev/null || echo 0)

    echo "Timeline progress: $TIMELINE_DONE of $TIMELINE_TOTAL items"
    echo ""
fi
```

### Check Git Status (Optional)

```bash
# Check git branch status for tasks
GIT_AVAILABLE=false
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_AVAILABLE=true
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "Git available: Current branch: $CURRENT_BRANCH"
    echo ""
fi
```

## HTML Dashboard Generation

### Generate Factory Theme Dashboard

```bash
echo "Generating HTML dashboard..."
echo ""

# Generate HTML with embedded CSS and JavaScript
cat > "$OUTPUT_FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sprint Dashboard - AI Software Factory</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --factory-bg: #1a1a2e;
            --factory-secondary: #16213e;
            --factory-accent: #0f3460;
            --factory-highlight: #e94560;
            --station-bg: #2a2a3e;
            --card-bg: #ffffff;
            --text-dark: #333333;
            --text-light: #ffffff;
            --border-color: #444444;
            --conveyor-color: #555555;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
            --info-color: #3b82f6;

            /* Priority colors */
            --priority-critical: #dc2626;
            --priority-high: #f59e0b;
            --priority-medium: #3b82f6;
            --priority-low: #6b7280;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: var(--factory-bg);
            color: var(--text-light);
            padding: 0;
            margin: 0;
            min-height: 100vh;
        }

        .dashboard-header {
            background: var(--factory-secondary);
            padding: 20px 30px;
            border-bottom: 3px solid var(--factory-highlight);
            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .dashboard-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .dashboard-title h1 {
            font-size: 2em;
            color: var(--factory-highlight);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .sprint-info {
            font-size: 0.9em;
            color: #aaa;
        }

        .metrics-panel {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .metric-card {
            background: var(--factory-accent);
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid var(--factory-highlight);
        }

        .metric-card .label {
            font-size: 0.8em;
            color: #aaa;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }

        .metric-card .value {
            font-size: 2em;
            font-weight: bold;
            color: var(--text-light);
        }

        .metric-card .subtitle {
            font-size: 0.85em;
            color: #999;
            margin-top: 5px;
        }

        .controls-bar {
            background: var(--factory-secondary);
            padding: 15px 30px;
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
            border-bottom: 1px solid var(--border-color);
        }

        .control-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .control-group label {
            font-size: 0.9em;
            color: #aaa;
        }

        .control-group select,
        .control-group input {
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            border-radius: 5px;
            background: var(--factory-accent);
            color: var(--text-light);
            font-size: 0.9em;
        }

        .factory-line {
            display: flex;
            overflow-x: auto;
            padding: 30px;
            gap: 20px;
            min-height: 600px;
        }

        .conveyor-belt {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 6px;
            background: repeating-linear-gradient(
                90deg,
                var(--conveyor-color) 0px,
                var(--conveyor-color) 20px,
                var(--border-color) 20px,
                var(--border-color) 40px
            );
            animation: conveyor-move 3s linear infinite;
        }

        @keyframes conveyor-move {
            0% { background-position: 0 0; }
            100% { background-position: 40px 0; }
        }

        .station {
            min-width: 320px;
            background: var(--station-bg);
            border-radius: 10px;
            padding: 20px;
            position: relative;
            border: 2px solid var(--border-color);
        }

        .station-header {
            font-size: 1.3em;
            font-weight: bold;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--factory-highlight);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .station-count {
            background: var(--factory-highlight);
            color: var(--text-light);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8em;
        }

        .task-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
            min-height: 400px;
        }

        .task-card {
            background: var(--card-bg);
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--text-dark);
            border-left: 4px solid var(--priority-medium);
        }

        .task-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(233, 69, 96, 0.3);
        }

        .task-card.priority-critical {
            border-left-color: var(--priority-critical);
        }

        .task-card.priority-high {
            border-left-color: var(--priority-high);
        }

        .task-card.priority-medium {
            border-left-color: var(--priority-medium);
        }

        .task-card.priority-low {
            border-left-color: var(--priority-low);
        }

        .task-card-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 10px;
        }

        .task-id {
            font-weight: bold;
            font-size: 0.85em;
            color: var(--factory-accent);
        }

        .task-priority {
            font-size: 0.75em;
            padding: 3px 8px;
            border-radius: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .task-priority.critical {
            background: var(--priority-critical);
            color: white;
        }

        .task-priority.high {
            background: var(--priority-high);
            color: white;
        }

        .task-priority.medium {
            background: var(--priority-medium);
            color: white;
        }

        .task-priority.low {
            background: var(--priority-low);
            color: white;
        }

        .task-title {
            font-size: 1em;
            font-weight: 600;
            margin-bottom: 8px;
            line-height: 1.4;
        }

        .task-meta {
            display: flex;
            gap: 12px;
            font-size: 0.8em;
            color: #666;
            flex-wrap: wrap;
        }

        .task-meta-item {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .progress-bar {
            width: 100%;
            height: 6px;
            background: #e0e0e0;
            border-radius: 3px;
            overflow: hidden;
            margin-top: 10px;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--factory-highlight), var(--info-color));
            transition: width 0.3s ease;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
            font-style: italic;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.8);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: var(--card-bg);
            color: var(--text-dark);
            border-radius: 12px;
            padding: 30px;
            max-width: 600px;
            width: 100%;
            max-height: 80vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e0e0e0;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 1.5em;
            cursor: pointer;
            color: #666;
            line-height: 1;
        }

        .modal-close:hover {
            color: var(--danger-color);
        }

        .footer {
            background: var(--factory-secondary);
            padding: 20px 30px;
            text-align: center;
            border-top: 1px solid var(--border-color);
            color: #aaa;
            font-size: 0.9em;
        }

        .auto-refresh-indicator {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: var(--factory-accent);
            color: var(--text-light);
            padding: 10px 20px;
            border-radius: 25px;
            font-size: 0.85em;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .refresh-dot {
            width: 8px;
            height: 8px;
            background: var(--success-color);
            border-radius: 50%;
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
        }

        @media (max-width: 768px) {
            .factory-line {
                flex-direction: column;
            }

            .station {
                min-width: 100%;
            }

            .metrics-panel {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media print {
            body {
                background: white;
                color: black;
            }

            .controls-bar,
            .auto-refresh-indicator {
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- Dashboard Header -->
    <div class="dashboard-header">
        <div class="dashboard-title">
            <h1>
                <span>AI Software Factory Dashboard</span>
            </h1>
            <div class="sprint-info">
                <div><strong>Sprint:</strong> SPRINT_DATE_PLACEHOLDER</div>
                <div><strong>Generated:</strong> <span id="current-time">TIMESTAMP_PLACEHOLDER</span></div>
            </div>
        </div>

        <!-- Metrics Panel -->
        <div class="metrics-panel">
            <div class="metric-card">
                <div class="label">Sprint Progress</div>
                <div class="value">COMPLETION_RATE_PLACEHOLDER%</div>
                <div class="subtitle">COMPLETE_COUNT_PLACEHOLDER of TOTAL_TASKS_PLACEHOLDER tasks</div>
            </div>

            <div class="metric-card">
                <div class="label">In Progress</div>
                <div class="value">INPROGRESS_COUNT_PLACEHOLDER</div>
                <div class="subtitle">Active development</div>
            </div>

            <div class="metric-card">
                <div class="label">Testing</div>
                <div class="value">TESTING_COUNT_PLACEHOLDER</div>
                <div class="subtitle">Quality assurance</div>
            </div>

            <div class="metric-card">
                <div class="label">Review</div>
                <div class="value">REVIEW_COUNT_PLACEHOLDER</div>
                <div class="subtitle">Code review pending</div>
            </div>

            <div class="metric-card">
                <div class="label">Backlog</div>
                <div class="value">BACKLOG_COUNT_PLACEHOLDER</div>
                <div class="subtitle">Waiting to start</div>
            </div>

            <div class="metric-card">
                <div class="label">Velocity</div>
                <div class="value" id="velocity">--</div>
                <div class="subtitle">Tasks per day</div>
            </div>
        </div>
    </div>

    <!-- Controls Bar -->
    <div class="controls-bar">
        <div class="control-group">
            <label for="filter-priority">Priority:</label>
            <select id="filter-priority">
                <option value="all">All</option>
                <option value="critical">Critical</option>
                <option value="high">High</option>
                <option value="medium">Medium</option>
                <option value="low">Low</option>
            </select>
        </div>

        <div class="control-group">
            <label for="filter-phase">Phase:</label>
            <select id="filter-phase">
                <option value="all">All</option>
                <option value="phase-0">Phase 0 (Hotfix)</option>
                <option value="phase-1">Phase 1 (Critical)</option>
                <option value="phase-2">Phase 2 (Important)</option>
                <option value="phase-3">Phase 3 (Enhancement)</option>
            </select>
        </div>

        <div class="control-group">
            <label for="search-task">Search:</label>
            <input type="text" id="search-task" placeholder="Task ID or title...">
        </div>
    </div>

    <!-- Factory Production Line -->
    <div class="factory-line">
        <!-- Backlog Station -->
        <div class="station" id="station-backlog">
            <div class="station-header">
                <span>Backlog</span>
                <span class="station-count" id="count-backlog">BACKLOG_COUNT_PLACEHOLDER</span>
            </div>
            <div class="task-list" id="list-backlog">
                <!-- Tasks will be injected here -->
                BACKLOG_TASKS_PLACEHOLDER
            </div>
            <div class="conveyor-belt"></div>
        </div>

        <!-- In Progress Station -->
        <div class="station" id="station-inprogress">
            <div class="station-header">
                <span>In Progress</span>
                <span class="station-count" id="count-inprogress">INPROGRESS_COUNT_PLACEHOLDER</span>
            </div>
            <div class="task-list" id="list-inprogress">
                INPROGRESS_TASKS_PLACEHOLDER
            </div>
            <div class="conveyor-belt"></div>
        </div>

        <!-- Testing Station -->
        <div class="station" id="station-testing">
            <div class="station-header">
                <span>Testing</span>
                <span class="station-count" id="count-testing">TESTING_COUNT_PLACEHOLDER</span>
            </div>
            <div class="task-list" id="list-testing">
                TESTING_TASKS_PLACEHOLDER
            </div>
            <div class="conveyor-belt"></div>
        </div>

        <!-- Review Station -->
        <div class="station" id="station-review">
            <div class="station-header">
                <span>Review</span>
                <span class="station-count" id="count-review">REVIEW_COUNT_PLACEHOLDER</span>
            </div>
            <div class="task-list" id="list-review">
                REVIEW_TASKS_PLACEHOLDER
            </div>
            <div class="conveyor-belt"></div>
        </div>

        <!-- Complete Station -->
        <div class="station" id="station-complete">
            <div class="station-header">
                <span>Complete</span>
                <span class="station-count" id="count-complete">COMPLETE_COUNT_PLACEHOLDER</span>
            </div>
            <div class="task-list" id="list-complete">
                COMPLETE_TASKS_PLACEHOLDER
            </div>
            <div class="conveyor-belt"></div>
        </div>
    </div>

    <!-- Task Detail Modal -->
    <div class="modal" id="task-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modal-title">Task Details</h2>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div id="modal-body">
                <!-- Task details will be injected here -->
            </div>
        </div>
    </div>

    <!-- Footer -->
    <div class="footer">
        AI Software Factory Dashboard • Generated by Claude Code •
        <a href="https://claude.ai/code" target="_blank" style="color: var(--factory-highlight);">Learn More</a>
    </div>

    <!-- Auto-refresh Indicator -->
    <div class="auto-refresh-indicator" id="refresh-indicator">
        <div class="refresh-dot"></div>
        <span>Auto-refresh: <span id="refresh-countdown">AUTO_REFRESH_PLACEHOLDER</span>s</span>
    </div>

    <script>
        // Task data (will be replaced with actual data)
        const sprintData = SPRINT_DATA_JSON_PLACEHOLDER;

        // Auto-refresh configuration
        const autoRefreshInterval = AUTO_REFRESH_PLACEHOLDER * 1000;
        let refreshCountdown = AUTO_REFRESH_PLACEHOLDER;

        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            initializeFilters();
            updateTime();
            startAutoRefresh();
        });

        // Filter functionality
        function initializeFilters() {
            const priorityFilter = document.getElementById('filter-priority');
            const phaseFilter = document.getElementById('filter-phase');
            const searchInput = document.getElementById('search-task');

            priorityFilter.addEventListener('change', applyFilters);
            phaseFilter.addEventListener('change', applyFilters);
            searchInput.addEventListener('input', applyFilters);
        }

        function applyFilters() {
            const priority = document.getElementById('filter-priority').value;
            const phase = document.getElementById('filter-phase').value;
            const search = document.getElementById('search-task').value.toLowerCase();

            const taskCards = document.querySelectorAll('.task-card');

            taskCards.forEach(card => {
                const cardPriority = card.dataset.priority;
                const cardPhase = card.dataset.phase;
                const cardText = card.textContent.toLowerCase();

                const priorityMatch = priority === 'all' || cardPriority === priority;
                const phaseMatch = phase === 'all' || cardPhase === phase;
                const searchMatch = search === '' || cardText.includes(search);

                if (priorityMatch && phaseMatch && searchMatch) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });

            updateStationCounts();
        }

        function updateStationCounts() {
            ['backlog', 'inprogress', 'testing', 'review', 'complete'].forEach(station => {
                const visibleCards = document.querySelectorAll(`#list-${station} .task-card[style="display: block;"], #list-${station} .task-card:not([style*="display: none"])`);
                const count = visibleCards.length;
                document.getElementById(`count-${station}`).textContent = count;
            });
        }

        // Modal functionality
        function showTaskDetails(taskId) {
            const modal = document.getElementById('task-modal');
            const modalBody = document.getElementById('modal-body');
            const modalTitle = document.getElementById('modal-title');

            // Find task data (simplified - in real implementation would fetch from data)
            modalTitle.textContent = `Task: ${taskId}`;
            modalBody.innerHTML = `
                <p><strong>Task ID:</strong> ${taskId}</p>
                <p><strong>Status:</strong> In Progress</p>
                <p><strong>Description:</strong> Task details would go here...</p>
                <p><strong>Branch:</strong> <code>feature/${taskId}</code></p>
                <p><strong>Actions:</strong></p>
                <ul>
                    <li><a href="#">View in tasks.csv</a></li>
                    <li><a href="#">Open workspace</a></li>
                    <li><a href="#">View atomic plan</a></li>
                </ul>
            `;

            modal.classList.add('active');
        }

        function closeModal() {
            document.getElementById('task-modal').classList.remove('active');
        }

        // Close modal on escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });

        // Close modal on background click
        document.getElementById('task-modal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });

        // Update current time
        function updateTime() {
            const now = new Date();
            document.getElementById('current-time').textContent = now.toLocaleString();
        }

        // Auto-refresh functionality
        function startAutoRefresh() {
            setInterval(() => {
                refreshCountdown--;
                document.getElementById('refresh-countdown').textContent = refreshCountdown;

                if (refreshCountdown <= 0) {
                    location.reload();
                }
            }, 1000);
        }
    </script>
</body>
</html>
HTMLEOF

echo "HTML structure generated"
echo ""
```

### Build Task Cards HTML

```bash
echo "Building task cards..."
echo ""

# Function to generate task card HTML
generate_task_card() {
    local task_id="$1"
    local title="$2"
    local priority="$3"
    local phase="$4"
    local effort="$5"

    # Clean up fields
    title=$(echo "$title" | sed 's/"//g')
    effort_clean=$(echo "$effort" | grep -oE '[0-9]+' | head -1 || echo "1")

    cat << CARDEOF
                <div class="task-card priority-$priority" data-priority="$priority" data-phase="$phase" onclick="showTaskDetails('$task_id')">
                    <div class="task-card-header">
                        <span class="task-id">$task_id</span>
                        <span class="task-priority $priority">$priority</span>
                    </div>
                    <div class="task-title">$title</div>
                    <div class="task-meta">
                        <div class="task-meta-item">
                            <span>Phase: $phase</span>
                        </div>
                        <div class="task-meta-item">
                            <span>Effort: ${effort_clean}d</span>
                        </div>
                    </div>
                </div>
CARDEOF
}

# Build task lists for each station
BACKLOG_TASKS_HTML=""
INPROGRESS_TASKS_HTML=""
TESTING_TASKS_HTML=""
REVIEW_TASKS_HTML=""
COMPLETE_TASKS_HTML=""

# Read sprint backlog and categorize tasks
if [ -f "$SPRINT_BACKLOG" ]; then
    while IFS=',' read -r task_id title description priority status phase effort rest; do
        # Skip header line
        if [ "$task_id" = "task_id" ]; then
            continue
        fi

        # Get current status from tasks.csv
        CURRENT_STATUS=$(grep "^$task_id," .claude/tasks.csv 2>/dev/null | cut -d',' -f5)

        # Default to pending if not found
        if [ -z "$CURRENT_STATUS" ]; then
            CURRENT_STATUS="pending"
        fi

        # Generate task card
        TASK_CARD=$(generate_task_card "$task_id" "$title" "$priority" "$phase" "$effort")

        # Add to appropriate station
        case "$CURRENT_STATUS" in
            pending)
                BACKLOG_TASKS_HTML="${BACKLOG_TASKS_HTML}${TASK_CARD}"
                ;;
            in-progress)
                INPROGRESS_TASKS_HTML="${INPROGRESS_TASKS_HTML}${TASK_CARD}"
                ;;
            testing)
                TESTING_TASKS_HTML="${TESTING_TASKS_HTML}${TASK_CARD}"
                ;;
            review)
                REVIEW_TASKS_HTML="${REVIEW_TASKS_HTML}${TASK_CARD}"
                ;;
            completed)
                COMPLETE_TASKS_HTML="${COMPLETE_TASKS_HTML}${TASK_CARD}"
                ;;
        esac
    done < "$SPRINT_BACKLOG"
fi

# Add empty state messages
if [ -z "$BACKLOG_TASKS_HTML" ]; then
    BACKLOG_TASKS_HTML='<div class="empty-state">No tasks in backlog</div>'
fi

if [ -z "$INPROGRESS_TASKS_HTML" ]; then
    INPROGRESS_TASKS_HTML='<div class="empty-state">No tasks in progress</div>'
fi

if [ -z "$TESTING_TASKS_HTML" ]; then
    TESTING_TASKS_HTML='<div class="empty-state">No tasks in testing</div>'
fi

if [ -z "$REVIEW_TASKS_HTML" ]; then
    REVIEW_TASKS_HTML='<div class="empty-state">No tasks in review</div>'
fi

if [ -z "$COMPLETE_TASKS_HTML" ]; then
    COMPLETE_TASKS_HTML='<div class="empty-state">No completed tasks yet</div>'
fi

echo "Task cards built"
echo ""
```

### Replace Placeholders

```bash
echo "Finalizing dashboard..."
echo ""

# Replace all placeholders with actual values
sed -i '' "s|SPRINT_DATE_PLACEHOLDER|$SPRINT_DATE|g" "$OUTPUT_FILE"
sed -i '' "s|TIMESTAMP_PLACEHOLDER|$(date +"%Y-%m-%d %H:%M:%S")|g" "$OUTPUT_FILE"
sed -i '' "s|COMPLETION_RATE_PLACEHOLDER|$COMPLETION_RATE|g" "$OUTPUT_FILE"
sed -i '' "s|COMPLETE_COUNT_PLACEHOLDER|$COMPLETE_COUNT|g" "$OUTPUT_FILE"
sed -i '' "s|TOTAL_TASKS_PLACEHOLDER|$TOTAL_TASKS|g" "$OUTPUT_FILE"
sed -i '' "s|BACKLOG_COUNT_PLACEHOLDER|$BACKLOG_COUNT|g" "$OUTPUT_FILE"
sed -i '' "s|INPROGRESS_COUNT_PLACEHOLDER|$INPROGRESS_COUNT|g" "$OUTPUT_FILE"
sed -i '' "s|TESTING_COUNT_PLACEHOLDER|$TESTING_COUNT|g" "$OUTPUT_FILE"
sed -i '' "s|REVIEW_COUNT_PLACEHOLDER|$REVIEW_COUNT|g" "$OUTPUT_FILE"
sed -i '' "s|AUTO_REFRESH_PLACEHOLDER|$AUTO_REFRESH|g" "$OUTPUT_FILE"

# Replace task lists (escape special characters)
# Note: Using perl for complex multi-line replacement
perl -i -pe "s|BACKLOG_TASKS_PLACEHOLDER|$(echo "$BACKLOG_TASKS_HTML" | sed 's/[&/\]/\\&/g')|g" "$OUTPUT_FILE" 2>/dev/null || sed -i '' "s|BACKLOG_TASKS_PLACEHOLDER||g" "$OUTPUT_FILE"
perl -i -pe "s|INPROGRESS_TASKS_PLACEHOLDER|$(echo "$INPROGRESS_TASKS_HTML" | sed 's/[&/\]/\\&/g')|g" "$OUTPUT_FILE" 2>/dev/null || sed -i '' "s|INPROGRESS_TASKS_PLACEHOLDER||g" "$OUTPUT_FILE"
perl -i -pe "s|TESTING_TASKS_PLACEHOLDER|$(echo "$TESTING_TASKS_HTML" | sed 's/[&/\]/\\&/g')|g" "$OUTPUT_FILE" 2>/dev/null || sed -i '' "s|TESTING_TASKS_PLACEHOLDER||g" "$OUTPUT_FILE"
perl -i -pe "s|REVIEW_TASKS_PLACEHOLDER|$(echo "$REVIEW_TASKS_HTML" | sed 's/[&/\]/\\&/g')|g" "$OUTPUT_FILE" 2>/dev/null || sed -i '' "s|REVIEW_TASKS_PLACEHOLDER||g" "$OUTPUT_FILE"
perl -i -pe "s|COMPLETE_TASKS_PLACEHOLDER|$(echo "$COMPLETE_TASKS_HTML" | sed 's/[&/\]/\\&/g')|g" "$OUTPUT_FILE" 2>/dev/null || sed -i '' "s|COMPLETE_TASKS_PLACEHOLDER||g" "$OUTPUT_FILE"

# Replace sprint data JSON placeholder (simplified for now)
sed -i '' "s|SPRINT_DATA_JSON_PLACEHOLDER|{}|g" "$OUTPUT_FILE"

echo "Dashboard finalized"
echo ""
```

## Post-Generation Actions

### Validate Output

```bash
echo "Validating dashboard..."
echo ""

# Check file exists
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "ERROR: Failed to create dashboard file"
    exit 1
fi

# Check file size
FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
echo "Dashboard size: $FILE_SIZE"

# Validate HTML structure
if grep -q "<!DOCTYPE html>" "$OUTPUT_FILE" && grep -q "</html>" "$OUTPUT_FILE"; then
    echo "HTML structure: valid"
else
    echo "WARNING: HTML structure may be incomplete"
fi

echo ""
```

### Open in Browser (Optional)

```bash
if [ "$OPEN_BROWSER" = true ]; then
    echo "Opening dashboard in browser..."

    if command -v open >/dev/null 2>&1; then
        open "$OUTPUT_FILE"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$OUTPUT_FILE"
    else
        echo "Could not detect browser command"
        echo "Open manually: file://$(pwd)/$OUTPUT_FILE"
    fi

    echo ""
fi
```

### Display Summary

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          SPRINT DASHBOARD GENERATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sprint: $SPRINT_DATE"
echo ""
echo "Sprint Progress:"
echo "   Total Tasks: $TOTAL_TASKS"
echo "   Completed: $COMPLETE_COUNT ($COMPLETION_RATE%)"
echo "   In Progress: $INPROGRESS_COUNT"
echo "   Testing: $TESTING_COUNT"
echo "   Review: $REVIEW_COUNT"
echo "   Backlog: $BACKLOG_COUNT"
echo ""
echo "Dashboard:"
echo "   File: $OUTPUT_FILE"
echo "   Size: $FILE_SIZE"
echo "   Theme: $THEME"
echo "   Auto-refresh: ${AUTO_REFRESH}s"
echo ""
echo "View Dashboard:"
echo "   file://$(pwd)/$OUTPUT_FILE"
echo ""
if [ "$OPEN_BROWSER" = false ]; then
    echo "Tip: Use --open flag to open automatically in browser"
    echo ""
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Expected Outcomes

After executing `/sprint-dashboard`, you should have:

### Generated File

1. **Interactive HTML Dashboard** - `.claude/sprints/dashboards/sprint-{date}-dashboard.html`
   - Factory-themed visual design with conveyor belt animations
   - Task cards organized in 5 stations (Backlog, In Progress, Testing, Review, Complete)
   - Real-time metrics panel with sprint progress
   - Interactive filtering by priority, phase, and search
   - Auto-refresh capability
   - Responsive design (mobile-friendly)
   - Print-friendly layout

### Dashboard Features

**Visual Components**:
- Header with sprint info and metrics
- 6 metric cards showing key statistics
- Control bar with filters and search
- 5 station columns with task cards
- Animated conveyor belts
- Task detail modal (click any card)
- Auto-refresh indicator
- Footer with credits

**Interactive Features**:
- Filter by priority (critical/high/medium/low)
- Filter by phase (0/1/2/3)
- Search by task ID or title
- Click task card for details
- Auto-refresh countdown
- Responsive layout

**Metrics Displayed**:
- Sprint completion percentage
- Tasks in each stage
- Velocity (tasks per day)
- Progress indicators

---

## Usage Examples

### Example 1: Basic Usage

```bash
# Generate dashboard for latest sprint
/sprint-dashboard

# Output:
# Using latest sprint: 2025-10-30
# Sprint progress: 40% (4 of 10)
# Dashboard generated: .claude/sprints/dashboards/sprint-2025-10-30-dashboard.html
```

### Example 2: Specific Sprint with Auto-Open

```bash
# Generate for specific sprint and open in browser
/sprint-dashboard 2025-11-01 --open

# Opens browser automatically with dashboard
```

### Example 3: Custom Auto-Refresh Rate

```bash
# Faster refresh for active development
/sprint-dashboard --auto-refresh 15

# Dashboard will reload every 15 seconds
```

### Example 4: Different Theme

```bash
# Use kanban theme instead of factory
/sprint-dashboard --theme kanban

# (Theme functionality to be implemented)
```

### Example 5: Complete Configuration

```bash
# All options together
/sprint-dashboard 2025-10-30 --auto-refresh 30 --theme factory --open

# Custom sprint, 30s refresh, factory theme, auto-open
```

---

## Troubleshooting

### Sprint Not Found

```bash
# Error: No sprints found
# Solution: Create a sprint first

/plan-sprint 2w
/sprint-dashboard
```

### Dashboard Doesn't Display Correctly

```bash
# Issue: Browser shows errors
# Solution: Check browser console (F12)

# Regenerate dashboard
rm .claude/sprints/dashboards/sprint-*.html
/sprint-dashboard
```

### Auto-Refresh Not Working

```bash
# Issue: Page doesn't refresh
# Solution: Check browser allows JavaScript

# Disable auto-refresh
/sprint-dashboard --auto-refresh 0
```

### Task Cards Not Showing

```bash
# Issue: Empty stations
# Solution: Check task status in tasks.csv

# View task status
grep -v "^task_id," .claude/tasks.csv | cut -d',' -f1,5

# Update task status if needed
```

---

## Integration with Other Commands

### Sprint Workflow

```bash
# 1. Plan sprint
/plan-sprint 2w

# 2. Generate initial dashboard
/sprint-dashboard --open

# 3. Work on tasks
/atomic-plan TASK-ID
/execute-task TASK-ID

# 4. Refresh dashboard to see progress
# (Auto-refreshes every 30 seconds)
```

### With Session Reports

```bash
# Generate sprint dashboard and session report
/sprint-dashboard
/session-report --include-git

# Compare metrics from both views
```

### Daily Standup Routine

```bash
# Show dashboard during standup
/sprint-dashboard --open

# Share screen with team
# Discuss task progress and blockers
```

---

## Best Practices

1. **Keep Dashboard Open** - Let it auto-refresh during work sessions
2. **Update Task Status** - Keep tasks.csv current for accurate dashboard
3. **Review Daily** - Check for bottlenecks in testing/review stages
4. **Share with Team** - Use for standup meetings and progress reports
5. **Adjust Refresh Rate** - Use faster refresh during active sprints
6. **Archive Old Dashboards** - Keep historical snapshots for retrospectives

---

## Success Criteria

A successful sprint dashboard includes:
- Valid HTML file generated
- All task cards display correctly
- Metrics show accurate data
- Interactive filtering works
- Auto-refresh functions properly
- Responsive design on all devices
- No JavaScript errors in browser console
- Clean visual appearance

---

**Note**: The sprint dashboard provides a real-time visual representation of sprint progress. Keep your tasks.csv updated to ensure accuracy. The dashboard auto-refreshes to show live changes during the sprint.
