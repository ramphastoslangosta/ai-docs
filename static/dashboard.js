/**
 * Task Dashboard JavaScript
 * Handles drag-and-drop, API communication, and UI updates
 */

// Global state
const state = {
    tasks: [],
    draggedTask: null,
    loading: false
};

// API endpoints
const API = {
    getTasks: '/api/tasks',
    moveTask: '/api/tasks/move',
    health: '/api/health'
};

/**
 * Initialize dashboard on page load
 */
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Dashboard] Initializing...');

    // Load tasks from API
    await loadTasks();

    // Setup drag-and-drop zones
    setupDropZones();

    // Setup auto-refresh (every 30 seconds)
    setInterval(loadTasks, 30000);

    console.log('[Dashboard] Initialization complete');
});

/**
 * Load tasks from API and render
 */
async function loadTasks() {
    showLoading(true);

    try {
        const response = await fetch(API.getTasks);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        state.tasks = data.tasks || [];

        console.log(`[Dashboard] Loaded ${state.tasks.length} tasks`);

        renderTasks();
        updateStats();
        updateLastUpdated();

    } catch (error) {
        console.error('[Dashboard] Error loading tasks:', error);
        showError(`Failed to load tasks: ${error.message}`);
    } finally {
        showLoading(false);
    }
}

/**
 * Render tasks in appropriate columns
 */
function renderTasks() {
    // Clear all columns
    const columns = ['backlog', 'planning', 'in-progress', 'review', 'deployed'];
    columns.forEach(column => {
        const zone = document.getElementById(`${column}-zone`);
        if (zone) {
            zone.innerHTML = '';
        }
    });

    // Render each task
    state.tasks.forEach(task => {
        const taskCard = createTaskCard(task);
        const column = task.column || 'backlog';
        const zone = document.getElementById(`${column}-zone`);

        if (zone) {
            zone.appendChild(taskCard);
        }
    });

    // Update column counts
    updateColumnCounts();
}

/**
 * Create a task card element
 */
function createTaskCard(task) {
    const card = document.createElement('div');
    card.className = 'task-card';
    card.draggable = true;
    card.dataset.taskId = task.task_id;
    card.dataset.status = task.status || 'pending';

    // Add priority class
    const priority = (task.priority || 'medium').toLowerCase();
    card.classList.add(`priority-${priority}`);

    // Build card HTML
    card.innerHTML = `
        <div class="task-header">
            <span class="task-id">${escapeHtml(task.task_id)}</span>
            <span class="task-priority priority-badge-${priority}">${escapeHtml(priority)}</span>
        </div>
        <div class="task-title">${escapeHtml(task.title || 'Untitled Task')}</div>
        <div class="task-description">${escapeHtml(task.description || '')}</div>
        <div class="task-footer">
            <span class="task-phase">${escapeHtml(task.phase || 'N/A')}</span>
            <span class="task-effort">${escapeHtml(task.estimated_effort || 'N/A')}</span>
        </div>
    `;

    // Add drag event listeners
    card.addEventListener('dragstart', handleDragStart);
    card.addEventListener('dragend', handleDragEnd);

    return card;
}

/**
 * Setup drop zones for drag-and-drop
 */
function setupDropZones() {
    const zones = document.querySelectorAll('.column-content');

    zones.forEach(zone => {
        zone.addEventListener('dragover', handleDragOver);
        zone.addEventListener('drop', handleDrop);
        zone.addEventListener('dragenter', handleDragEnter);
        zone.addEventListener('dragleave', handleDragLeave);
    });
}

/**
 * Handle drag start event
 */
function handleDragStart(e) {
    const card = e.target;
    state.draggedTask = {
        id: card.dataset.taskId,
        status: card.dataset.status,
        element: card
    };

    card.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', card.innerHTML);

    console.log(`[Dashboard] Drag started: ${state.draggedTask.id}`);
}

/**
 * Handle drag end event
 */
function handleDragEnd(e) {
    const card = e.target;
    card.classList.remove('dragging');

    // Remove drag-over class from all zones
    document.querySelectorAll('.column-content').forEach(zone => {
        zone.classList.remove('drag-over');
    });

    state.draggedTask = null;
}

/**
 * Handle drag over event
 */
function handleDragOver(e) {
    e.preventDefault(); // Allow drop
    e.dataTransfer.dropEffect = 'move';
    return false;
}

/**
 * Handle drag enter event
 */
function handleDragEnter(e) {
    const zone = e.target.closest('.column-content');
    if (zone) {
        zone.classList.add('drag-over');
    }
}

/**
 * Handle drag leave event
 */
function handleDragLeave(e) {
    const zone = e.target.closest('.column-content');
    if (zone && !zone.contains(e.relatedTarget)) {
        zone.classList.remove('drag-over');
    }
}

/**
 * Handle drop event
 */
async function handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();

    const zone = e.target.closest('.column-content');
    if (!zone || !state.draggedTask) {
        return;
    }

    zone.classList.remove('drag-over');

    const newColumn = zone.dataset.column;
    const oldStatus = state.draggedTask.status;

    console.log(`[Dashboard] Drop: ${state.draggedTask.id} -> ${newColumn}`);

    // Move task via API
    await moveTaskToColumn(state.draggedTask.id, oldStatus, newColumn);
}

/**
 * Move task to new column via API
 */
async function moveTaskToColumn(taskId, oldStatus, newColumn) {
    showLoading(true);

    try {
        const response = await fetch(API.moveTask, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                task_id: taskId,
                old_status: oldStatus,
                new_status: newColumn
            })
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || `HTTP ${response.status}`);
        }

        const result = await response.json();
        console.log('[Dashboard] Task moved:', result);

        showSuccess(`Task ${taskId} moved to ${newColumn}`);

        // Reload tasks to show updated state
        await loadTasks();

    } catch (error) {
        console.error('[Dashboard] Error moving task:', error);
        showError(`Failed to move task: ${error.message}`);

        // Reload tasks to restore correct state
        await loadTasks();
    } finally {
        showLoading(false);
    }
}

/**
 * Update dashboard statistics
 */
function updateStats() {
    const totalTasks = state.tasks.length;
    const inProgressCount = state.tasks.filter(t =>
        t.column === 'in-progress' || t.status === 'in-progress'
    ).length;
    const completedCount = state.tasks.filter(t =>
        t.column === 'deployed' || t.status === 'completed' || t.status === 'archived'
    ).length;

    document.getElementById('total-tasks').textContent = totalTasks;
    document.getElementById('in-progress-count').textContent = inProgressCount;
    document.getElementById('completed-count').textContent = completedCount;
}

/**
 * Update column counts
 */
function updateColumnCounts() {
    const columns = ['backlog', 'planning', 'in-progress', 'review', 'deployed'];

    columns.forEach(column => {
        const zone = document.getElementById(`${column}-zone`);
        const count = zone ? zone.children.length : 0;

        const badge = document.querySelector(`.column-count[data-column="${column}"]`);
        if (badge) {
            badge.textContent = count;
        }
    });
}

/**
 * Update last updated timestamp
 */
function updateLastUpdated() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString();
    const element = document.getElementById('last-updated');

    if (element) {
        element.textContent = `Last updated: ${timeStr}`;
    }
}

/**
 * Show/hide loading overlay
 */
function showLoading(show) {
    state.loading = show;
    const overlay = document.getElementById('loading-overlay');

    if (overlay) {
        overlay.classList.toggle('hidden', !show);
    }
}

/**
 * Show error toast message
 */
function showError(message) {
    const toast = document.getElementById('error-toast');
    const messageEl = toast.querySelector('.error-message');

    if (messageEl) {
        messageEl.textContent = message;
    }

    toast.classList.remove('hidden');

    // Auto-hide after 5 seconds
    setTimeout(() => {
        toast.classList.add('hidden');
    }, 5000);
}

/**
 * Show success toast message
 */
function showSuccess(message) {
    const toast = document.getElementById('success-toast');
    const messageEl = toast.querySelector('.success-message');

    if (messageEl) {
        messageEl.textContent = message;
    }

    toast.classList.remove('hidden');

    // Auto-hide after 3 seconds
    setTimeout(() => {
        toast.classList.add('hidden');
    }, 3000);
}

/**
 * Escape HTML to prevent XSS
 */
function escapeHtml(text) {
    if (!text) return '';

    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };

    return text.toString().replace(/[&<>"']/g, m => map[m]);
}

// Log initialization
console.log('[Dashboard] Script loaded');
