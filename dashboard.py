#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "fastapi>=0.104.0",
#     "uvicorn[standard]>=0.24.0",
# ]
# ///

"""
Interactive Kanban Dashboard Server
Reads tasks.csv and provides drag-and-drop task management with real-time updates.

Usage:
    uv run dashboard.py                          # Default port 8000
    uv run dashboard.py --port 3000              # Custom port
    uv run dashboard.py --csv-path /path/tasks.csv  # Custom CSV path
    uv run dashboard.py --open                   # Auto-open browser
"""

import argparse
import csv
import os
import sys
import webbrowser
from pathlib import Path
from typing import List, Dict, Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

# Initialize FastAPI app
app = FastAPI(
    title="Task Dashboard",
    description="Interactive Kanban board for task management",
    version="1.0.0"
)

# Mount static files directory
app.mount("/static", StaticFiles(directory="static"), name="static")

# Global configuration
config = {
    "csv_path": ".claude/tasks.csv",  # Default path
    "port": 8000,
    "auto_open": False
}


class TaskMoveRequest(BaseModel):
    """Request model for moving tasks between columns"""
    task_id: str
    old_status: str
    new_status: str


def find_tasks_csv() -> Path:
    """
    Find tasks.csv in common locations

    Returns:
        Path to tasks.csv

    Raises:
        FileNotFoundError if tasks.csv not found
    """
    search_paths = [
        config["csv_path"],
        "tasks.csv",
        ".claude/tasks.csv",
        "../tasks.csv"
    ]

    for path in search_paths:
        p = Path(path)
        if p.exists():
            return p.resolve()

    raise FileNotFoundError(
        f"tasks.csv not found. Searched: {', '.join(search_paths)}"
    )


def read_tasks_csv(csv_path: Path) -> List[Dict[str, Any]]:
    """
    Read tasks from CSV file

    Args:
        csv_path: Path to tasks.csv

    Returns:
        List of task dictionaries
    """
    tasks = []

    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                tasks.append(dict(row))
    except Exception as e:
        print(f"Error reading CSV: {e}", file=sys.stderr)
        return []

    return tasks


def write_tasks_csv(csv_path: Path, tasks: List[Dict[str, Any]]) -> bool:
    """
    Write tasks to CSV file

    Args:
        csv_path: Path to tasks.csv
        tasks: List of task dictionaries

    Returns:
        True if successful, False otherwise
    """
    try:
        if not tasks:
            return False

        # Get fieldnames from first task
        fieldnames = list(tasks[0].keys())

        with open(csv_path, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(tasks)

        return True
    except Exception as e:
        print(f"Error writing CSV: {e}", file=sys.stderr)
        return False


def map_status_to_column(status: str) -> str:
    """
    Map task status to Kanban column

    Args:
        status: Task status from CSV

    Returns:
        Column name for Kanban board
    """
    status_map = {
        "pending": "backlog",
        "planning": "planning",
        "in-progress": "in-progress",
        "review": "review",
        "completed": "deployed",
        "blocked": "backlog",  # Blocked tasks go to backlog
        "archived": "deployed"  # Archived tasks go to deployed
    }

    return status_map.get(status.lower(), "backlog")


def map_column_to_status(column: str) -> str:
    """
    Map Kanban column to task status

    Args:
        column: Column name from Kanban board

    Returns:
        Task status for CSV
    """
    column_map = {
        "backlog": "pending",
        "planning": "planning",
        "in-progress": "in-progress",
        "review": "review",
        "deployed": "completed"
    }

    return column_map.get(column.lower(), "pending")


@app.get("/", response_class=HTMLResponse)
async def serve_dashboard():
    """Serve the main dashboard HTML page"""
    html_path = Path("static/dashboard.html")

    if not html_path.exists():
        return HTMLResponse(
            content="<h1>Error: dashboard.html not found</h1>"
                    "<p>Please ensure static/dashboard.html exists</p>",
            status_code=404
        )

    return HTMLResponse(content=html_path.read_text(encoding='utf-8'))


@app.get("/api/tasks", response_class=JSONResponse)
async def get_tasks():
    """
    Get all tasks from CSV

    Returns:
        JSON array of tasks with columns mapped
    """
    try:
        csv_path = find_tasks_csv()
        tasks = read_tasks_csv(csv_path)

        # Add column information to each task
        for task in tasks:
            task['column'] = map_status_to_column(task.get('status', 'pending'))

        return JSONResponse(content={"tasks": tasks, "count": len(tasks)})

    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading tasks: {str(e)}")


@app.post("/api/tasks/move")
async def move_task(request: TaskMoveRequest):
    """
    Move a task to a different column

    Args:
        request: TaskMoveRequest with task_id, old_status, new_status

    Returns:
        JSON response with success status
    """
    try:
        csv_path = find_tasks_csv()
        tasks = read_tasks_csv(csv_path)

        # Find task by ID
        task_found = False
        for task in tasks:
            if task.get('task_id') == request.task_id:
                task_found = True
                old_status = task.get('status', '')

                # Map column to status
                new_status = map_column_to_status(request.new_status)
                task['status'] = new_status

                print(f"Moved task {request.task_id}: {old_status} -> {new_status}")
                break

        if not task_found:
            raise HTTPException(
                status_code=404,
                detail=f"Task {request.task_id} not found"
            )

        # Write updated tasks back to CSV
        if not write_tasks_csv(csv_path, tasks):
            raise HTTPException(
                status_code=500,
                detail="Failed to update tasks.csv"
            )

        return JSONResponse(content={
            "success": True,
            "task_id": request.task_id,
            "new_status": new_status
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error moving task: {str(e)}"
        )


@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    try:
        csv_path = find_tasks_csv()
        task_count = len(read_tasks_csv(csv_path))

        return JSONResponse(content={
            "status": "healthy",
            "csv_path": str(csv_path),
            "task_count": task_count
        })
    except Exception as e:
        return JSONResponse(
            content={"status": "unhealthy", "error": str(e)},
            status_code=500
        )


def parse_args():
    """Parse command-line arguments"""
    parser = argparse.ArgumentParser(
        description="Interactive Kanban Dashboard Server"
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8000,
        help="Port to run server on (default: 8000)"
    )
    parser.add_argument(
        "--csv-path",
        type=str,
        default=".claude/tasks.csv",
        help="Path to tasks.csv (default: .claude/tasks.csv)"
    )
    parser.add_argument(
        "--open",
        action="store_true",
        help="Automatically open dashboard in browser"
    )

    return parser.parse_args()


def main():
    """Main entry point"""
    args = parse_args()

    # Update global config
    config["csv_path"] = args.csv_path
    config["port"] = args.port
    config["auto_open"] = args.open

    # Verify tasks.csv exists
    try:
        csv_path = find_tasks_csv()
        print(f"[Dashboard] Found tasks.csv: {csv_path}")
    except FileNotFoundError as e:
        print(f"[Dashboard] ERROR: {e}", file=sys.stderr)
        print("[Dashboard] Please create tasks.csv or specify path with --csv-path")
        sys.exit(1)

    # Verify static directory exists
    static_dir = Path("static")
    if not static_dir.exists():
        print("[Dashboard] Creating static/ directory...")
        static_dir.mkdir(parents=True, exist_ok=True)

    # Check for dashboard.html
    dashboard_html = static_dir / "dashboard.html"
    if not dashboard_html.exists():
        print(f"[Dashboard] WARNING: {dashboard_html} not found")
        print("[Dashboard] Dashboard will not display correctly")

    # Auto-open browser
    if config["auto_open"]:
        url = f"http://localhost:{config['port']}"
        print(f"[Dashboard] Opening browser: {url}")
        webbrowser.open(url)

    # Start server
    import uvicorn

    print(f"[Dashboard] Starting server on port {config['port']}...")
    print(f"[Dashboard] Visit: http://localhost:{config['port']}")
    print("[Dashboard] Press Ctrl+C to stop")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=config["port"],
        log_level="info"
    )


if __name__ == "__main__":
    main()
