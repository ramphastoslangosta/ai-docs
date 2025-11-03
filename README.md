# AI Task Management System

An **AI-powered task management and code review system** built around Claude Code slash commands and agents. Transform code review findings into actionable, tracked development work with atomic commit strategies, interactive Kanban dashboards, and comprehensive documentation.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green.svg)](https://fastapi.tiangolo.com/)

## 🚀 Features

### Interactive Kanban Dashboard
- **Drag-and-drop task management** across 5 workflow zones
- **Real-time CSV persistence** - automatic status updates
- **Factory-themed visualization** with animated progress indicators
- **RESTful API** for programmatic access
- **Responsive design** for desktop and mobile

### AI-Powered Workflows
- **Code review automation** with OWASP/SOLID compliance checks
- **Task generation** from code review findings
- **Atomic execution plans** with test checkpoints
- **Sprint planning** with capacity calculation
- **Session reporting** with visual infographics

### Command-Based Architecture
- `/code-review` - Comprehensive codebase analysis
- `/generate_tasks` - Create structured task packages
- `/atomic-plan` - Generate step-by-step execution plans
- `/execute-task` - Implement tasks with test checkpoints
- `/dashboard` - Launch interactive Kanban board
- `/plan-sprint` - Organize work into time-boxed iterations
- `/sprint-dashboard` - Factory view of development pipeline
- `/session-report` - Visual progress summaries

## 📊 Quick Start

### Prerequisites

- Python 3.11+ (managed by `uv`)
- Git
- [uv](https://github.com/astral-sh/uv) (Python package installer)

### Installation

```bash
# Clone the repository
git clone https://github.com/ramphastoslangosta/ai-docs.git
cd ai-docs

# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# That's it! No manual installation needed - uv handles dependencies
```

### Launch the Dashboard

```bash
# Start the interactive Kanban dashboard
uv run dashboard.py --port 8000 --open

# Or with custom port
uv run dashboard.py --port 3000 --open
```

Open your browser to [http://localhost:8000](http://localhost:8000) and start managing tasks!

## 🎯 Core Workflow

```
/code-review → /generate_tasks → /atomic-plan → /execute-task
     ↓              ↓                 ↓              ↓
  Analysis      Task CSV          Workspace      Implementation
```

### Example Usage

```bash
# 1. Analyze your codebase
/code-review full

# 2. Generate actionable tasks from review
/generate_tasks

# 3. Plan the first task
/atomic-plan TASK-20250929-001

# 4. Execute with guided steps
/execute-task TASK-20250929-001

# 5. Visualize progress
/dashboard --open
```

## 📁 Project Structure

```
ai-docs/
├── dashboard.py              # Interactive Kanban server
├── static/                   # Dashboard frontend
│   ├── dashboard.html        # Kanban board UI
│   ├── dashboard.js          # Drag-and-drop logic
│   └── dashboard.css         # Factory theme
├── .claude/
│   ├── commands/             # Slash command definitions
│   │   ├── dashboard.md
│   │   ├── code-review.md
│   │   ├── atomic-plan.md
│   │   └── ...
│   ├── agents/               # AI agents
│   │   ├── code-reviewer-architect.md
│   │   └── task-package-generator.md
│   ├── workspace/            # Task workspaces
│   ├── tasks.csv             # Task tracking database
│   └── tests/                # Test suites
└── docs/                     # Documentation & reports
```

## 🎨 Dashboard Features

### Phase 1 (Current)
- ✅ Drag-and-drop task cards
- ✅ Automatic CSV updates
- ✅ Real-time UI refresh
- ✅ 5 workflow zones (Backlog → Planning → In Progress → Review → Deployed)
- ✅ Color-coded priorities (critical, high, medium, low)
- ✅ Factory-themed design
- ✅ RESTful API

### Phase 2 (Planned)
- 🔄 Command execution on card drop
- 🔄 Right-click context menus
- 🔄 Automated workflow triggers

### Phase 3 (Planned)
- 🔄 WebSocket streaming
- 🔄 Real-time Claude output display
- 🔄 Multi-user synchronization

### Phase 4 (Planned)
- 🔄 Async task queue
- 🔄 Parallel command execution
- 🔄 Worker pool management

## 🧪 Testing

The project includes comprehensive test coverage:

```bash
# Run dashboard tests
bash .claude/tests/test_dashboard_scaffold.sh

# Results: 15/16 automated tests passed (93.75%)
#          6/6 CSV functionality tests passed (100%)
```

**Test Coverage:**
- Command file validation
- YAML frontmatter syntax
- API endpoint definitions
- Drag-and-drop functionality
- CSV read/write operations
- Error handling
- HTML/CSS/JS validation

## 📖 Documentation

- **[CLAUDE.md](.claude/CLAUDE.md)** - Comprehensive system guide
- **[Commands](/.claude/commands/)** - Individual command specifications
- **[Examples](/.claude/docs/examples/)** - Usage examples and patterns
- **[Session Reports](/docs/session-reports/)** - Progress dashboards

## 🔧 Technology Stack

- **Backend**: FastAPI + uvicorn
- **Frontend**: Vanilla HTML/CSS/JavaScript (no frameworks)
- **Package Management**: uv (inline dependencies)
- **Data Storage**: CSV (file-based, no database)
- **AI Integration**: Claude Code SDK
- **Testing**: Bash test scaffolds + automated validation

## 📊 Task Management

Tasks are tracked in `.claude/tasks.csv` with the following structure:

```csv
task_id,title,description,priority,status,phase,estimated_effort,dependencies,branch_name,pr_template,test_file,notes
```

**Task ID Patterns:**
- `TASK-YYYYMMDD-NNN` - General development
- `ARCH-YYYYMMDD-NNN` - Architecture refactoring
- `HOTFIX-YYYYMMDD-NNN` - Emergency fixes
- `PROCESS-YYYYMMDD-NNN` - Process improvements

**Status Values:** `pending`, `in-progress`, `review`, `completed`, `deployed`

**Priority Levels:** `critical`, `high`, `medium`, `low`

## 🤝 Contributing

This is a personal project showcasing AI-powered development workflows. However, if you find it useful:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Claude Code](https://claude.ai/code)
- Inspired by [agentic-drop-zones](https://github.com/disler/agentic-drop-zones)
- FastAPI framework
- uv package manager

## 📧 Contact

- GitHub: [@ramphastoslangosta](https://github.com/ramphastoslangosta)
- Email: rafaellangmillet@gmail.com

---

**⭐ If you find this project useful, please consider starring it on GitHub!**

## 🎬 Demo

![Dashboard Demo](docs/images/dashboard-demo.gif)

*Interactive Kanban dashboard with drag-and-drop task management*

## 📈 Project Stats

- **Commands**: 13+ slash commands
- **Agents**: 2 specialized AI agents
- **Test Coverage**: 93.75% (automated) + 100% (CSV functionality)
- **Lines of Code**: 10,000+ (including documentation)
- **Active Development**: Yes

---

Made with ❤️ and Claude Code
