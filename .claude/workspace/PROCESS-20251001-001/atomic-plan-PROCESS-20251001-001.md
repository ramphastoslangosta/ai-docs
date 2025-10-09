# Atomic Execution Plan: PROCESS-20251001-001
## Route Extraction Protocol Documentation

**Task ID:** PROCESS-20251001-001
**Title:** Route Extraction Protocol - Formalize Safe Extraction Process
**Priority:** HIGH
**Estimated Effort:** 1 week (5 days)
**Phase:** 0 (Hotfix Prevention)
**Branch:** process/route-extraction-protocol-20251001
**Created:** October 2, 2025

---

## Executive Summary

Create comprehensive documentation (`docs/ROUTE-EXTRACTION-PROTOCOL.md`) that formalizes the safe route extraction process to prevent future incidents like HOTFIX-20251001-001. This protocol will serve as the authoritative guide for all future route extractions, incorporating lessons learned from the quotes router incident where missing data processing logic caused production failures.

**Impact:** Prevents production incidents, reduces deployment risk, standardizes refactoring process.

---

## Success Criteria

1. ✅ **Documentation Complete**: `docs/ROUTE-EXTRACTION-PROTOCOL.md` created with all required sections
2. ✅ **Actionable Checklists**: Pre-extraction, extraction, testing, deployment, and rollback checklists ready to use
3. ✅ **Real-world Examples**: Include HOTFIX-20251001-001 as case study demonstrating what to avoid
4. ✅ **Integration with Workflow**: Referenced in `CLAUDE.md` and `.claude/commands/` for easy access
5. ✅ **Team Review**: Document reviewed and approved (or feedback incorporated)

---

## Risk Assessment

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| Documentation too generic | MEDIUM | 40% | Use concrete examples from real incidents |
| Protocol too complex | LOW | 20% | Include quick-reference checklists |
| Not followed by team | HIGH | 60% | Integrate into slash commands and CI/CD |
| Protocol becomes outdated | MEDIUM | 50% | Schedule quarterly reviews |

**Overall Risk Level:** MEDIUM (manageable with proper execution)

---

## Time Estimates

| Phase | Duration | Details |
|-------|----------|---------|
| Preparation | 30 min | Research, setup workspace |
| Implementation | 3-4 hours | Write protocol document |
| Integration | 1 hour | Update references, create templates |
| Testing | 30 min | Review with checklist |
| Documentation | 30 min | Update related docs |
| **TOTAL** | **6-7 hours** | ~1 work day |

---

## PHASE 1: PREPARATION (Pre-work)

**Duration:** 30 minutes

### Step 1: Environment Setup
**Action:** Create workspace and gather reference materials

**Files:**
- Create: `.claude/workspace/PROCESS-20251001-001/`
- Read: `HOTFIX-20251001-RCA.md`, `TASK-012-ROLLBACK-REPORT.md`, `app/routes/quotes.py`

**Commands:**
```bash
# Create workspace
mkdir -p .claude/workspace/PROCESS-20251001-001
cd .claude/workspace/PROCESS-20251001-001

# Create reference notes
cat > references.md << 'EOF'
# Reference Materials

## Incidents to Learn From
1. HOTFIX-20251001-001 - Quotes router data processing failure
2. TASK-012 rollback - Duplicate route removal premature

## Successful Extractions
1. TASK-001 - Auth routes (Sept 30, 2025)
2. TASK-003 - Work orders and materials (Sept 30, 2025)

## Key Files
- app/routes/quotes.py (659 lines)
- app/presenters/quote_presenter.py (presenter pattern fix)
- app/routes/auth.py (successful extraction example)
- app/routes/work_orders.py (successful extraction example)
EOF
```

**Test Checkpoint:**
```bash
# Verify workspace created
ls -la .claude/workspace/PROCESS-20251001-001/
cat .claude/workspace/PROCESS-20251001-001/references.md
```

**Success Indicator:** Workspace created, reference materials documented

---

### Step 2: Analyze Past Incidents
**Action:** Review HOTFIX-20251001-001 RCA to extract key lessons

**Files:**
- Read: `HOTFIX-20251001-RCA.md` (lines 1-797)
- Read: `app/routes/quotes.py` (lines 1-659)
- Read: `app/presenters/quote_presenter.py` (presenter pattern implementation)

**Commands:**
```bash
# Extract key findings
grep -A 5 "Root Cause" HOTFIX-20251001-RCA.md > key-findings.txt
grep -A 10 "What Went Wrong" HOTFIX-20251001-RCA.md >> key-findings.txt
grep -A 15 "What Should Have Been Done" HOTFIX-20251001-RCA.md >> key-findings.txt

# Document anti-patterns
cat > anti-patterns.md << 'EOF'
# Anti-Patterns to Avoid

1. **Router without data processing** - app/routes/quotes.py returned raw Quote objects
2. **Missing template compatibility testing** - No tests for template data requirements
3. **Premature duplicate removal** - TASK-012 attempted before router verification
4. **No integration tests** - Only unit tests existed
5. **Insufficient deployment verification** - Router deployed without template smoke tests

# Patterns to Follow

1. **Presenter Pattern** - app/presenters/quote_presenter.py (HOTFIX-20251001-001 fix)
2. **Keep duplicates during transition** - main.py kept old routes until verification
3. **Integration testing** - tests/test_integration_quotes_routes.py (13 tests)
4. **Gradual rollout** - Test env first, production after verification
EOF
```

**Test Checkpoint:**
```bash
wc -l key-findings.txt anti-patterns.md
cat anti-patterns.md
```

**Success Indicator:** Key findings documented, anti-patterns identified

---

### Step 3: Create Branch and Initial Structure
**Action:** Create git branch and protocol document skeleton

**Files:**
- Create: `docs/ROUTE-EXTRACTION-PROTOCOL.md` (skeleton)

**Commands:**
```bash
# Create branch
git checkout -b process/route-extraction-protocol-20251001

# Create docs directory if needed
mkdir -p docs

# Create protocol skeleton
cat > docs/ROUTE-EXTRACTION-PROTOCOL.md << 'EOF'
# Route Extraction Protocol
## Safe Process for Moving Routes from main.py to Modular Routers

**Version:** 1.0
**Created:** October 2, 2025
**Last Updated:** October 2, 2025
**Status:** 🔴 DRAFT

---

## Table of Contents

1. [Overview](#overview)
2. [When to Use This Protocol](#when-to-use)
3. [Pre-Extraction Checklist](#pre-extraction)
4. [Extraction Steps](#extraction-steps)
5. [Testing Requirements](#testing-requirements)
6. [Deployment Protocol](#deployment-protocol)
7. [Rollback Plan](#rollback-plan)
8. [Case Studies](#case-studies)
9. [Quick Reference](#quick-reference)

---

[Content to be added in implementation phase]

EOF
```

**Test Checkpoint:**
```bash
git status
cat docs/ROUTE-EXTRACTION-PROTOCOL.md
```

**Commit Message:**
```
docs(protocol): create route extraction protocol skeleton

- Created docs/ROUTE-EXTRACTION-PROTOCOL.md structure
- Added table of contents
- Prepared for content implementation

Task: PROCESS-20251001-001
Branch: process/route-extraction-protocol-20251001
```

**Rollback:** `git checkout main -- docs/`

**Time Estimate:** 10 minutes

**Success Indicator:** Branch created, skeleton file exists

---

### Step 4: Define Success Criteria in Workspace
**Action:** Create detailed success criteria checklist

**Files:**
- Create: `.claude/workspace/PROCESS-20251001-001/success-criteria.md`

**Commands:**
```bash
cd .claude/workspace/PROCESS-20251001-001

cat > success-criteria.md << 'EOF'
# Success Criteria: PROCESS-20251001-001

## Documentation Completeness
- [ ] All 9 sections completed (Overview → Quick Reference)
- [ ] Minimum 500 lines of actionable content
- [ ] At least 2 real-world case studies included
- [ ] All checklists have 5+ items each

## Quality Standards
- [ ] Every step has concrete example
- [ ] All bash commands tested and verified
- [ ] File paths reference actual project structure
- [ ] Anti-patterns clearly documented with "what not to do"

## Integration Requirements
- [ ] Referenced in CLAUDE.md
- [ ] Linked from TASK_QUICKSTART.md
- [ ] Available via /docs slash command (if exists)
- [ ] Template files created for reuse

## Usability Verification
- [ ] Can complete pre-extraction checklist in <10 minutes
- [ ] Extraction steps unambiguous (no interpretation needed)
- [ ] Testing requirements measurable (pass/fail criteria)
- [ ] Deployment protocol includes exact commands

## Case Study Inclusion
- [ ] HOTFIX-20251001-001 documented as "What Not to Do"
- [ ] TASK-001 (auth) documented as "What to Do"
- [ ] Side-by-side comparison included

## Team Adoption
- [ ] Document reviewed by at least 1 team member
- [ ] Feedback incorporated
- [ ] Action items assigned for enforcement

---

**Completion Definition:**
All checkboxes above marked complete, document merged to main branch.
EOF
```

**Test Checkpoint:**
```bash
cat success-criteria.md
grep "\\[ \\]" success-criteria.md | wc -l  # Should show 20+ criteria
```

**Success Indicator:** Success criteria documented with 20+ checkpoints

---

## PHASE 2: IMPLEMENTATION (Core Content Creation)

**Duration:** 3-4 hours

### Step 5: Write Overview and When to Use Sections
**Action:** Add foundational sections to protocol document

**Files:**
- Modify: `docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Content to Add:**
```markdown
## 1. Overview

### Purpose

This protocol provides a **step-by-step, battle-tested process** for safely extracting routes from `main.py` into modular routers under `app/routes/`. It was created in response to **HOTFIX-20251001-001**, a production incident caused by incomplete route extraction.

**Key Principle:** **Gradual transition with parallel operation** until verified.

### Background

The FastAPI Window Quotation System originally had all routes in a 2,273-line `main.py`. During refactoring (TASK-001, TASK-002, TASK-003), routes were extracted to:
- `app/routes/auth.py` ✅ Successful
- `app/routes/quotes.py` ⚠️ Caused production incident
- `app/routes/materials.py` ✅ Successful
- `app/routes/work_orders.py` ✅ Successful

**The quotes router incident revealed critical gaps in our extraction process.**

### Core Philosophy

```
KEEP OLD → ADD NEW → TEST BOTH → VERIFY NEW → REMOVE OLD
     ↓          ↓          ↓           ↓            ↓
  Safe      Parallel   Redundancy  Confidence   Clean
```

**NOT:** ~~Remove old → Add new → Hope it works~~ ❌

---

## 2. When to Use This Protocol

### Required Situations

Use this protocol for:

✅ **Any route extraction from main.py to modular routers**
✅ **Refactoring routes that involve data processing**
✅ **Routes with template dependencies**
✅ **Routes with complex business logic**
✅ **High-traffic production endpoints**

### Optional Situations (Still Recommended)

Consider using for:
- New route creation (follow structure, skip extraction steps)
- Internal API endpoints (lower risk)
- Development-only routes

### When NOT to Use

Skip this protocol for:
- ❌ Static file routes
- ❌ Health check endpoints
- ❌ OpenAPI documentation routes

---
```

**Commands:**
```bash
# Edit the protocol document
nano docs/ROUTE-EXTRACTION-PROTOCOL.md
# Or use your preferred editor

# Verify word count (should be 200+ words)
wc -w docs/ROUTE-EXTRACTION-PROTOCOL.md
```

**Test Checkpoint:**
```bash
# Verify sections exist
grep "## 1. Overview" docs/ROUTE-EXTRACTION-PROTOCOL.md
grep "## 2. When to Use" docs/ROUTE-EXTRACTION-PROTOCOL.md

# Verify content quality
wc -w docs/ROUTE-EXTRACTION-PROTOCOL.md  # Should show 300+ words
```

**Commit Message:**
```
docs(protocol): add overview and usage guidance

- Documented protocol purpose and background
- Explained core philosophy: gradual transition with verification
- Defined when to use this protocol
- Referenced HOTFIX-20251001-001 incident

Task: PROCESS-20251001-001
```

**Rollback:** `git checkout HEAD~1 -- docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Time Estimate:** 30 minutes

---

### Step 6: Create Pre-Extraction Checklist
**Action:** Add comprehensive pre-extraction checklist (Section 3)

**Files:**
- Modify: `docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Content to Add:**
```markdown
## 3. Pre-Extraction Checklist

**STOP!** Before writing any code, complete this checklist. This prevents 90% of extraction bugs.

### 3.1 Route Identification

- [ ] **Route path identified** (e.g., `@app.get("/quotes")`)
- [ ] **HTTP methods documented** (GET, POST, PUT, DELETE)
- [ ] **Authentication requirements** (cookie, bearer, flexible, none)
- [ ] **Response type** (HTMLResponse, JSONResponse, RedirectResponse)

**Example:**
```python
# Route: /quotes
@app.get("/quotes", response_class=HTMLResponse)
async def quotes_list_page(request: Request, db: Session = Depends(get_db)):
    user = await get_current_user_from_cookie(request, db)
    if not user:
        return RedirectResponse(url="/login")
    # ... processing logic ...
```

**Document:** Route path, methods, auth, response type

---

### 3.2 Dependency Analysis

- [ ] **Database services used** (list all: `DatabaseQuoteService`, etc.)
- [ ] **External services** (PDF service, CSV service, etc.)
- [ ] **Helper functions** (calculation functions, formatters)
- [ ] **Imports required** (models, enums, types)

**How to Find:**
```bash
# Find all imports in route function
grep -A 50 "def your_route_function" main.py | grep -E "(Service|from|import)"

# Find database calls
grep -A 50 "def your_route_function" main.py | grep "\.db\."
```

**Document:** Complete dependency tree

---

### 3.3 Data Processing Logic

- [ ] **Raw data extraction** (from database, request params)
- [ ] **Data transformation** (calculations, formatting, aggregation)
- [ ] **Presentation logic** (prepare for templates)
- [ ] **Pagination/filtering** (query modifications)

**Critical:** If your route does ANY data processing before passing to templates, you MUST extract it.

**HOTFIX-20251001-001 Lesson:**
```python
# ❌ WRONG: Router returns raw database objects
quotes = quote_service.get_quotes_by_user(user.id)
return templates.TemplateResponse("quotes_list.html", {"quotes": quotes})

# ✅ RIGHT: Router returns processed data via presenter
quotes = quote_service.get_quotes_by_user(user.id)
processed_quotes = QuoteListPresenter.present(quotes)
return templates.TemplateResponse("quotes_list.html", {"quotes": processed_quotes})
```

**Tool to identify processing logic:**
```bash
# Find calculations/transformations in route
grep -A 100 "def your_route" main.py | grep -E "(for .* in|\.append\(|calculate|format|transform)"
```

**Document:** All processing steps in route

---

### 3.4 Template Requirements

- [ ] **Template file identified** (e.g., `templates/quotes_list.html`)
- [ ] **Template variables documented** (all `{{ variable }}` references)
- [ ] **Required data shape** (dict keys, object attributes)
- [ ] **Optional data** (fields that can be null)

**How to find template requirements:**
```bash
# List all template variables
grep -oE '\{\{[^}]+\}\}' templates/your_template.html | sort -u

# Find loops and conditionals
grep -E '{% (for|if)' templates/your_template.html
```

**Example template analysis:**
```html
<!-- templates/quotes_list.html expects: -->
{% for quote in quotes %}
  {{ quote.id }}                 <!-- REQUIRED: integer -->
  {{ quote.client_name }}        <!-- REQUIRED: string -->
  {{ quote.total_area }}         <!-- REQUIRED: calculated field ⚠️ -->
  {{ quote.price_per_m2 }}       <!-- REQUIRED: calculated field ⚠️ -->
  {{ quote.sample_items }}       <!-- REQUIRED: transformed list ⚠️ -->
{% endfor %}
```

**Document:** Template contract (input/output specification)

---

### 3.5 Test Coverage Analysis

- [ ] **Existing tests found** (unit, integration, e2e)
- [ ] **Test coverage measured** (pytest --cov)
- [ ] **Missing tests identified** (template rendering, data processing)
- [ ] **Test strategy documented** (what new tests needed)

**Commands:**
```bash
# Find existing tests for route
grep -r "test.*quotes" tests/

# Measure coverage
pytest tests/ --cov=app.routes --cov-report=term-missing

# Identify gaps
grep -L "test_.*_template" tests/test_*.py
```

**Document:** Current coverage % and gaps

---

### 3.6 Deployment Risk Assessment

**Answer these questions:**

1. **Traffic volume:** How many requests/day does this route handle?
   - Low (<100) = Lower risk
   - Medium (100-1000) = Medium risk
   - High (>1000) = High risk

2. **Business criticality:** What breaks if this route fails?
   - Minor inconvenience = Lower risk
   - Feature unavailable = Medium risk
   - Revenue impact = High risk

3. **User visibility:** Who uses this route?
   - Developers only = Lower risk
   - Internal team = Medium risk
   - End users = High risk

4. **Data sensitivity:** Does route handle sensitive data?
   - Public data = Lower risk
   - User data = Medium risk
   - Financial/PII = High risk

**Risk Matrix:**

| Risk Level | Protocol Adjustments |
|------------|---------------------|
| **LOW** | Standard protocol, can skip some verification |
| **MEDIUM** | Full protocol, 24-hour monitoring period |
| **HIGH** | Full protocol + staged rollout + feature flag |

---

### 3.7 Rollback Plan

- [ ] **Backup created** (git tag or branch)
- [ ] **Rollback steps documented** (exact commands)
- [ ] **Rollback testing** (verify rollback works)
- [ ] **Communication plan** (who to notify if rollback needed)

**Template:**
```bash
# Rollback Plan for [ROUTE_NAME] Extraction

## Quick Rollback (if router fails)
git revert [COMMIT_HASH]
git push origin main
docker-compose restart app

## Full Rollback (if issues discovered later)
git checkout [BACKUP_TAG]
git push origin main --force  # USE WITH CAUTION
docker-compose down && docker-compose up -d

## Verification after rollback
curl http://localhost:8000/your-route  # Should return 200
grep "ERROR" logs/app.log  # Should be empty
```

---

### Pre-Extraction Checklist Summary

**Before proceeding to extraction, you must have:**

1. ✅ Route fully documented (path, methods, auth, response)
2. ✅ All dependencies identified (services, functions, imports)
3. ✅ Data processing logic mapped (calculations, transformations)
4. ✅ Template requirements specified (variables, data shape)
5. ✅ Test coverage analyzed (existing tests, gaps)
6. ✅ Risk assessed (traffic, criticality, visibility)
7. ✅ Rollback plan created (backup, commands, communication)

**Estimated time:** 30-60 minutes (pays off in prevention)

---
```

**Test Checkpoint:**
```bash
# Verify checklist exists and is complete
grep "^- \[ \]" docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l  # Should show 25+ checkboxes

# Verify code examples included
grep "```python" docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l  # Should show 3+ examples

# Verify bash commands included
grep "```bash" docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l  # Should show 5+ commands
```

**Commit Message:**
```
docs(protocol): add comprehensive pre-extraction checklist

- 7 major checklist sections with 25+ verification items
- Dependency analysis tools and commands
- Data processing anti-patterns from HOTFIX-20251001-001
- Template requirements analysis guide
- Risk assessment matrix
- Rollback plan template

Task: PROCESS-20251001-001
```

**Rollback:** `git checkout HEAD~1 -- docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Time Estimate:** 60 minutes

---

### Step 7: Document Extraction Steps
**Action:** Add step-by-step extraction process (Section 4)

**Files:**
- Modify: `docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Content to Add:**
```markdown
## 4. Extraction Steps

**Critical Rule:** **NEVER remove the original route until the new router is verified in production.**

### 4.1 Create Router File

**Action:** Create new router file in `app/routes/`

**File structure:**
```
app/
├── routes/
│   ├── __init__.py
│   ├── auth.py          # Authentication routes
│   ├── quotes.py        # Quote management routes
│   ├── work_orders.py   # Work order routes
│   └── [your_new_router].py  ← Create this
```

**Template:**
```python
# app/routes/[your_feature].py
from fastapi import APIRouter, Depends, Request, HTTPException, status
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from sqlalchemy.orm import Session
from typing import List

# Import database and dependencies
from database import get_db, [YourModels]
from app.dependencies.auth import get_current_user_from_cookie
from config import templates

# Import services
from database import [YourDatabaseServices]

# Import models
from models.[your_models] import [YourPydanticModels]

# Create router
router = APIRouter(
    prefix="",  # Keep empty for backward compatibility
    tags=["your-feature"]
)

# Routes will be added in next steps
```

**Commands:**
```bash
# Create router file
touch app/routes/your_feature.py

# Verify imports work
python -c "from app.routes import your_feature; print('✓ Import successful')"
```

**Commit after this step:**
```
refactor: create [feature] router skeleton

- Created app/routes/your_feature.py
- Added router imports and structure
- No routes implemented yet

Task: PROCESS-20251001-001
```

---

### 4.2 Extract Route Handler Function

**Action:** Copy route function to new router file

**Steps:**

1. **Copy the entire route function** from `main.py`
2. **Paste into router file**
3. **Replace `@app.get/post/put/delete` with `@router.get/post/put/delete`**
4. **Keep original in main.py commented out**

**Example:**

```python
# In app/routes/quotes.py

@router.get("/quotes", response_class=HTMLResponse)
async def quotes_list_page(
    request: Request,
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(25, ge=1, le=100, description="Items per page"),
    db: Session = Depends(get_db)
):
    """Quote list page with pagination"""
    user = await get_current_user_from_cookie(request, db)
    if not user:
        return RedirectResponse(url="/login")

    # ... rest of function (copied verbatim from main.py) ...
```

**In main.py:**
```python
# TASK-XXX: Route moved to app/routes/quotes.py (keep for rollback)
# @app.get("/quotes", response_class=HTMLResponse)
# async def quotes_list_page(request: Request, ...):
#     ... (keep original code commented) ...
```

**Test immediately:**
```bash
# Verify syntax
python -c "from app.routes.quotes import router; print(f'✓ Router has {len(router.routes)} routes')"
```

**Commit after this step:**
```
refactor: extract [route_name] to router

- Copied route handler to app/routes/your_feature.py
- Converted @app decorator to @router decorator
- Original route commented in main.py for rollback

Task: PROCESS-20251001-001
```

---

### 4.3 Extract Data Processing Logic

**⚠️ CRITICAL STEP - This is where HOTFIX-20251001-001 went wrong**

**Action:** Identify and extract ALL data processing before template rendering

**How to identify data processing:**

```python
# Look for these patterns in your route:

# 1. List comprehensions
processed_items = [transform(item) for item in raw_items]

# 2. Dictionary building
data = {"key": calculation(value), "total": sum(items)}

# 3. Calculations
total_area = sum(item.width * item.height for item in items)

# 4. Formatting
formatted_date = date.strftime("%Y-%m-%d")

# 5. Filtering/sorting
filtered = [x for x in items if x.status == "active"]
```

**Decision tree:**

```
Is there ANY code between database query and template rendering?
    YES → Extract to Presenter class
    NO → Route can return raw data directly
```

**Presenter Pattern (Recommended):**

```python
# app/presenters/quote_presenter.py

class QuoteListPresenter:
    """Processes raw Quote objects for template rendering"""

    @staticmethod
    def present(quotes: List[Quote]) -> List[dict]:
        """
        Convert raw Quote objects to template-ready dictionaries

        Args:
            quotes: Raw Quote objects from database

        Returns:
            List of dicts with calculated fields for template
        """
        processed_quotes = []

        for quote in quotes:
            # Extract quote_data
            quote_data = quote.quote_data if quote.quote_data else {}
            items = quote_data.get('items', [])

            # Calculate derived fields
            total_area = sum(
                float(item.get('area_m2', 0)) * item.get('quantity', 1)
                for item in items
            )

            price_per_m2 = (
                float(quote.total_final) / total_area
                if total_area > 0 else 0
            )

            # Get sample items for preview
            sample_items = [
                f"{item.get('window_type', 'N/A')} "
                f"{item.get('width_cm')}x{item.get('height_cm')}cm"
                for item in items[:3]
            ]

            # Build template-ready dict
            processed_quotes.append({
                'id': quote.id,
                'client_name': quote.client_name,
                'created_at': quote.created_at,
                'total_final': quote.total_final,
                'items_count': len(items),
                'total_area': round(total_area, 2),
                'price_per_m2': round(price_per_m2, 2),
                'sample_items': sample_items
            })

        return processed_quotes
```

**Update router to use presenter:**

```python
# app/routes/quotes.py

from app.presenters.quote_presenter import QuoteListPresenter

@router.get("/quotes", response_class=HTMLResponse)
async def quotes_list_page(request: Request, db: Session = Depends(get_db)):
    user = await get_current_user_from_cookie(request, db)
    if not user:
        return RedirectResponse(url="/login")

    # Get raw data from database
    quote_service = DatabaseQuoteService(db)
    quotes = quote_service.get_quotes_by_user(user.id, limit=50)

    # ✅ PROCESS DATA via presenter
    processed_quotes = QuoteListPresenter.present(quotes)

    # Pass processed data to template
    return templates.TemplateResponse("quotes_list.html", {
        "request": request,
        "title": "Mis Cotizaciones",
        "user": user,
        "quotes": processed_quotes  # ← Processed, not raw
    })
```

**Test checkpoint:**
```bash
# Test presenter in isolation
python -c "
from app.presenters.quote_presenter import QuoteListPresenter
print('✓ QuoteListPresenter imported')

# Test with mock data
mock_quote = type('Quote', (), {
    'id': 1,
    'client_name': 'Test',
    'created_at': '2025-01-01',
    'total_final': 1000,
    'quote_data': {'items': [{'area_m2': 2.5, 'quantity': 2}]}
})

result = QuoteListPresenter.present([mock_quote])
assert 'total_area' in result[0], 'Missing calculated field'
print('✓ Presenter processes data correctly')
"
```

**Commit after this step:**
```
refactor: extract data processing to presenter

- Created app/presenters/quote_presenter.py
- Moved 85 lines of processing logic from route
- Router now returns processed data to template
- Fixes pattern that caused HOTFIX-20251001-001

Task: PROCESS-20251001-001
```

---

### 4.4 Update Database Service (If Needed)

**Action:** Check if database service needs pagination, filtering, or sorting

**HOTFIX-20251001-001 Lesson:** Database service lacked `offset` parameter

**Before:**
```python
# database.py (WRONG - missing offset)
def get_quotes_by_user(self, user_id: uuid.UUID, limit: int = 50):
    return (self.db.query(Quote)
            .filter(Quote.user_id == user_id)
            .order_by(Quote.created_at.desc())
            .limit(limit)  # ← Missing .offset()
            .all())
```

**After:**
```python
# database.py (CORRECT - with offset)
def get_quotes_by_user(self, user_id: uuid.UUID, limit: int = 50, offset: int = 0):
    """
    Get quotes by user with pagination support

    Args:
        user_id: User UUID
        limit: Maximum results to return
        offset: Number of results to skip (for pagination)
    """
    return (self.db.query(Quote)
            .filter(Quote.user_id == user_id)
            .order_by(Quote.created_at.desc())
            .offset(offset)  # ← Added for pagination
            .limit(limit)
            .all())
```

**Test database service:**
```bash
python -c "
from database import SessionLocal, DatabaseQuoteService
import uuid

db = SessionLocal()
service = DatabaseQuoteService(db)

# Test with offset
user_id = uuid.uuid4()
page_1 = service.get_quotes_by_user(user_id, limit=10, offset=0)
page_2 = service.get_quotes_by_user(user_id, limit=10, offset=10)

print(f'✓ Pagination works: Page 1={len(page_1)}, Page 2={len(page_2)}')
db.close()
"
```

**Commit after this step:**
```
fix(database): add offset parameter for pagination

- Added offset parameter to get_quotes_by_user()
- Enables proper pagination in quote routes
- Prevents pagination bug from HOTFIX-20251001-001

Task: PROCESS-20251001-001
```

---

### 4.5 Register Router in main.py

**Action:** Add router to main.py using `app.include_router()`

**Steps:**

1. Import router at top of main.py
2. Call `app.include_router()` after middleware setup
3. **Keep original route commented** (DO NOT DELETE YET)

**Code:**

```python
# main.py (add at top with other imports)
from app.routes import quotes as quote_routes

# main.py (add after middleware, before route definitions)
# === TASK-XXX: Add Quotes Router ===
from app.routes import quotes as quote_routes
app.include_router(quote_routes.router)
# NOTE: Original route kept below for rollback (remove after verification)
```

**Test router registration:**
```bash
# Check app routes
python -c "
import main
routes = [r for r in main.app.routes if hasattr(r, 'path')]
quote_routes = [r for r in routes if '/quotes' in r.path]
print(f'✓ Found {len(quote_routes)} quote routes')
for route in quote_routes:
    print(f'  - {list(route.methods)} {route.path}')
"
```

**Expected output:**
```
✓ Found 2 quote routes
  - ['GET'] /quotes  ← From router
  - ['GET'] /quotes  ← From main.py (commented but still registered if not properly commented)
```

**⚠️ If you see duplicate routes, verify original is properly commented in main.py**

**Commit after this step:**
```
refactor: register quotes router in main.py

- Imported app.routes.quotes
- Registered router with app.include_router()
- Original route kept commented for rollback
- Verified router registration with route count

Task: PROCESS-20251001-001
```

---

### 4.6 Verify Both Routes Work (Parallel Operation)

**Action:** Test that BOTH the router route and original route work identically

**Why:** This catches integration issues before deployment

**Test checklist:**

- [ ] **Start app:** `python main.py` or `docker-compose up`
- [ ] **Test router route:** Should work via `app.include_router()`
- [ ] **Test original route:** Should work if uncommented temporarily
- [ ] **Compare responses:** Identical HTML/JSON output
- [ ] **Test error cases:** 401, 404, 500 scenarios

**Test script:**
```bash
# test_both_routes.sh

echo "🔄 Testing parallel operation..."

# Start app in background
python main.py &
APP_PID=$!
sleep 5  # Wait for startup

# Test router route
echo "Testing router route..."
ROUTER_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/quotes)
echo "  Router: $ROUTER_RESPONSE"

# Temporarily uncomment original route (manual step)
echo "⚠️  Manually uncomment original route in main.py, then press Enter"
read

# Restart app
kill $APP_PID
python main.py &
APP_PID=$!
sleep 5

# Test original route
ORIGINAL_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/quotes)
echo "  Original: $ORIGINAL_RESPONSE"

# Stop app
kill $APP_PID

# Compare
if [ "$ROUTER_RESPONSE" = "$ORIGINAL_RESPONSE" ]; then
    echo "✅ Both routes return same status code"
else
    echo "❌ Routes return different status codes!"
    echo "   Router: $ROUTER_RESPONSE"
    echo "   Original: $ORIGINAL_RESPONSE"
    exit 1
fi
```

**Manual verification:**
1. Access http://localhost:8000/quotes in browser
2. Verify page renders correctly
3. Check browser console for errors
4. Test pagination, filters, sorting
5. Verify all links work

**Commit after this step:**
```
test: verify router and original routes work identically

- Tested router route returns correct status codes
- Verified HTML rendering matches original
- Confirmed no JavaScript errors in console
- Both routes operate in parallel successfully

Task: PROCESS-20251001-001
```

---

### 4.7 Keep Original Route for Rollback

**Action:** Leave original route commented in main.py

**Format:**

```python
# ============================================================================
# TASK-XXX: ROUTE EXTRACTION - DO NOT REMOVE UNTIL PRODUCTION VERIFIED
# ============================================================================
# This route was extracted to app/routes/quotes.py
# Kept here for emergency rollback if router fails in production
#
# To rollback:
# 1. Uncomment this route
# 2. Comment out app.include_router(quote_routes.router)
# 3. Restart app
#
# REMOVAL TIMELINE:
# - Test environment: After 24 hours of successful operation
# - Production: After 1 week of successful operation with no errors
#
# @app.get("/quotes", response_class=HTMLResponse)
# async def quotes_list_page(request: Request, db: Session = Depends(get_db)):
#     user = await get_current_user_from_cookie(request, db)
#     if not user:
#         return RedirectResponse(url="/login")
#
#     quote_service = DatabaseQuoteService(db)
#     quotes = quote_service.get_quotes_by_user(user.id, limit=50)
#
#     # [Original processing logic kept here...]
#     processed_quotes = []
#     for quote in quotes:
#         # ... all processing ...
#         processed_quotes.append({...})
#
#     return templates.TemplateResponse("quotes_list.html", {
#         "request": request,
#         "quotes": processed_quotes,
#         ...
#     })
#
# ============================================================================
```

**Benefits:**
- Easy emergency rollback (uncomment + restart)
- Code reference for debugging
- Prevents "what did the old code do?" questions

**Timeline for removal:**
- **Test environment:** 24-48 hours after successful deployment
- **Production:** 1 week after successful deployment with zero errors

**Commit after this step:**
```
docs: document rollback process for extracted route

- Added detailed rollback instructions
- Kept original route commented with timeline
- Specified removal criteria (1 week zero errors)

Task: PROCESS-20251001-001
```

---

### Extraction Steps Summary

**Completed when:**
1. ✅ Router file created (`app/routes/your_feature.py`)
2. ✅ Route handler extracted to router
3. ✅ Data processing extracted to presenter (if needed)
4. ✅ Database service updated (pagination, filtering)
5. ✅ Router registered in main.py
6. ✅ Both routes verified working
7. ✅ Original route kept for rollback

**Total commits:** 7 atomic commits

**Next:** Proceed to Testing Requirements (Section 5)

---
```

**Test Checkpoint:**
```bash
# Verify extraction steps complete
grep "### 4\." docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l  # Should show 7 steps

# Verify code examples
grep "```python" docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l  # Should show 10+ examples

# Verify includes HOTFIX lessons
grep -i "HOTFIX-20251001-001" docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l  # Should show 3+ mentions
```

**Commit Message:**
```
docs(protocol): add detailed extraction steps with examples

- 7 step-by-step extraction phases
- Presenter pattern implementation guide
- Database service update requirements
- Parallel operation verification
- Rollback preservation strategy
- Code examples from HOTFIX-20251001-001 incident

Task: PROCESS-20251001-001
```

**Rollback:** `git checkout HEAD~1 -- docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Time Estimate:** 90 minutes

---

## PHASE 3: INTEGRATION PHASE

**Duration:** 1 hour

### Step 8: Add Testing Requirements Section
**Action:** Document comprehensive testing strategy (Section 5)

**Files:**
- Modify: `docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Content:** [Include testing checklist with unit tests, integration tests, template tests, pagination tests]

**Time Estimate:** 30 minutes

---

### Step 9: Add Deployment Protocol Section
**Action:** Document safe deployment process (Section 6)

**Files:**
- Modify: `docs/ROUTE-EXTRACTION-PROTOCOL.md`

**Content:** [Include test environment deployment, production deployment, monitoring, verification steps]

**Time Estimate:** 30 minutes

---

## PHASE 4: DOCUMENTATION PHASE

**Duration:** 30 minutes

### Step 10: Add Case Studies and Quick Reference
**Action:** Complete final sections with real examples (Sections 7-9)

**Content:**
- Case Study 1: HOTFIX-20251001-001 (What Not to Do)
- Case Study 2: TASK-001 Auth Routes (What to Do)
- Quick Reference Checklists

**Time Estimate:** 20 minutes

---

### Step 11: Update Project Documentation
**Action:** Link protocol from main documentation files

**Files:**
- Modify: `CLAUDE.md`
- Modify: `TASK_QUICKSTART.md`
- Modify: `.claude/commands/` (if applicable)

**Changes:**
```markdown
# In CLAUDE.md, add to Development Notes section:

### Route Extraction Protocol

When extracting routes from main.py to modular routers, **always follow the Route Extraction Protocol**:

📖 **See:** [docs/ROUTE-EXTRACTION-PROTOCOL.md](docs/ROUTE-EXTRACTION-PROTOCOL.md)

**Key principles:**
- Keep original route until new router verified in production
- Extract ALL data processing to presenter classes
- Add integration tests for template rendering
- Deploy gradually with monitoring
```

**Time Estimate:** 10 minutes

---

## PHASE 5: REVIEW AND FINALIZE

**Duration:** 30 minutes

### Step 12: Self-Review and Validation
**Action:** Review document against success criteria

**Checklist:**
- [ ] All 9 sections complete
- [ ] Code examples tested
- [ ] Bash commands verified
- [ ] Cross-references accurate
- [ ] No typos or broken links
- [ ] Meets 500+ line requirement

**Commands:**
```bash
# Word count
wc -w docs/ROUTE-EXTRACTION-PROTOCOL.md

# Line count
wc -l docs/ROUTE-EXTRACTION-PROTOCOL.md

# Check for broken references
grep -E '\[.*\]\(.*\)' docs/ROUTE-EXTRACTION-PROTOCOL.md | grep -v "http"
```

**Time Estimate:** 15 minutes

---

### Step 13: Final Commit and Documentation Update
**Action:** Commit final version and update task status

**Commands:**
```bash
# Final commit
git add docs/ROUTE-EXTRACTION-PROTOCOL.md CLAUDE.md TASK_QUICKSTART.md
git commit -m "docs(protocol): complete route extraction protocol v1.0

- All 9 sections completed with 500+ lines
- Pre-extraction checklist (7 sections, 25+ items)
- Step-by-step extraction process (7 phases)
- Testing requirements (unit, integration, template)
- Deployment protocol (test → production)
- Rollback plan and emergency procedures
- 2 case studies (HOTFIX-20251001-001, TASK-001)
- Quick reference checklists
- Integrated with CLAUDE.md and TASK_QUICKSTART.md

Prevents: Future router extraction incidents
Addresses: HOTFIX-20251001-001 root cause
Status: ✅ READY FOR REVIEW

Task: PROCESS-20251001-001
Branch: process/route-extraction-protocol-20251001
"

# Push to remote
git push origin process/route-extraction-protocol-20251001

# Create PR
gh pr create --title "PROCESS-20251001-001: Route Extraction Protocol v1.0" \
             --body "$(cat <<'EOF'
## Summary

Creates comprehensive Route Extraction Protocol to prevent future incidents like HOTFIX-20251001-001.

## Changes

- ✅ Created `docs/ROUTE-EXTRACTION-PROTOCOL.md` (500+ lines)
- ✅ 7-section pre-extraction checklist
- ✅ 7-phase extraction process with code examples
- ✅ Testing requirements (unit + integration + template)
- ✅ Deployment protocol (test → production)
- ✅ Rollback procedures
- ✅ 2 case studies with lessons learned
- ✅ Quick reference checklists
- ✅ Integrated with project documentation

## Case Studies Included

1. **HOTFIX-20251001-001** - What NOT to do (router without data processing)
2. **TASK-001** - What to do (successful auth route extraction)

## Benefits

- Prevents production incidents from incomplete extractions
- Standardizes refactoring process across team
- Provides actionable checklists for every extraction
- Documents rollback procedures for safety
- Captures institutional knowledge from incidents

## Testing

- [x] All code examples syntax-checked
- [x] Bash commands verified
- [x] Cross-references validated
- [x] Meets 500+ line requirement
- [x] Passes self-review checklist

## Review Checklist

- [ ] Protocol is actionable and unambiguous
- [ ] Code examples are correct and tested
- [ ] Checklists cover all critical steps
- [ ] Case studies accurately reflect incidents
- [ ] No missing prerequisites or dependencies
- [ ] Timeline for adoption realistic

## Next Steps

After merge:
1. Announce protocol to development team
2. Add to onboarding documentation
3. Schedule protocol review (quarterly)
4. Track adherence in future extractions

## References

- HOTFIX-20251001-001 RCA
- TASK-001, TASK-002, TASK-003 (completed extractions)
- TASK-012 rollback report

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Time Estimate:** 15 minutes

---

## Rollback Strategy

### Full Rollback (Emergency)

**Scenario:** Protocol document has critical errors that need immediate removal

**Steps:**
```bash
# 1. Revert to main
git checkout main

# 2. Delete branch
git branch -D process/route-extraction-protocol-20251001

# 3. Recreate workspace
rm -rf .claude/workspace/PROCESS-20251001-001
mkdir -p .claude/workspace/PROCESS-20251001-001

# 4. Restart from Step 1
# Follow atomic plan from beginning
```

**Time:** 5 minutes

---

### Partial Rollback (Fix Section)

**Scenario:** One section needs rewriting but rest is good

**Steps:**
```bash
# 1. Identify commit to revert to
git log --oneline docs/ROUTE-EXTRACTION-PROTOCOL.md

# 2. Checkout file from specific commit
git checkout [COMMIT_HASH] -- docs/ROUTE-EXTRACTION-PROTOCOL.md

# 3. Re-implement section
nano docs/ROUTE-EXTRACTION-PROTOCOL.md

# 4. Commit fix
git add docs/ROUTE-EXTRACTION-PROTOCOL.md
git commit -m "fix(protocol): rewrite [section] with corrections"
```

**Time:** 15-30 minutes depending on section

---

## Success Verification

### Documentation Completeness Check

```bash
#!/bin/bash
# verify_protocol.sh

PROTOCOL_FILE="docs/ROUTE-EXTRACTION-PROTOCOL.md"

echo "🔍 Verifying Route Extraction Protocol..."
echo ""

# Check file exists
if [ ! -f "$PROTOCOL_FILE" ]; then
    echo "❌ Protocol file not found: $PROTOCOL_FILE"
    exit 1
fi

# Check sections exist
SECTIONS=(
    "## 1. Overview"
    "## 2. When to Use"
    "## 3. Pre-Extraction Checklist"
    "## 4. Extraction Steps"
    "## 5. Testing Requirements"
    "## 6. Deployment Protocol"
    "## 7. Rollback Plan"
    "## 8. Case Studies"
    "## 9. Quick Reference"
)

MISSING=0
for SECTION in "${SECTIONS[@]}"; do
    if grep -q "$SECTION" "$PROTOCOL_FILE"; then
        echo "✅ $SECTION"
    else
        echo "❌ $SECTION - MISSING"
        MISSING=$((MISSING + 1))
    fi
done

echo ""

# Check line count
LINES=$(wc -l < "$PROTOCOL_FILE")
echo "📊 Line count: $LINES"
if [ "$LINES" -lt 500 ]; then
    echo "⚠️  Warning: Document is less than 500 lines (target: 500+)"
fi

# Check code examples
CODE_BLOCKS=$(grep -c '```' "$PROTOCOL_FILE")
echo "📝 Code examples: $CODE_BLOCKS"
if [ "$CODE_BLOCKS" -lt 20 ]; then
    echo "⚠️  Warning: Less than 20 code examples (target: 20+)"
fi

# Check checkboxes
CHECKBOXES=$(grep -c '\- \[ \]' "$PROTOCOL_FILE")
echo "☑️  Checklists: $CHECKBOXES items"
if [ "$CHECKBOXES" -lt 25 ]; then
    echo "⚠️  Warning: Less than 25 checklist items (target: 25+)"
fi

echo ""

# Summary
if [ "$MISSING" -eq 0 ] && [ "$LINES" -ge 500 ]; then
    echo "✅ Protocol document COMPLETE and meets quality standards"
    exit 0
else
    echo "❌ Protocol document INCOMPLETE or below quality standards"
    echo "   Missing sections: $MISSING"
    echo "   Line count: $LINES / 500"
    exit 1
fi
```

**Run verification:**
```bash
chmod +x verify_protocol.sh
./verify_protocol.sh
```

---

## Total Time Summary

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Preparation | 30 min | 30 min |
| Implementation | 3-4 hours | 4-4.5 hours |
| Integration | 1 hour | 5-5.5 hours |
| Documentation | 30 min | 5.5-6 hours |
| Review | 30 min | **6-6.5 hours** |

**Total Estimated Time:** 6-7 hours (~1 work day)

---

## Post-Completion Actions

### Update Task Status
```bash
# Mark task as completed in tasks.csv (when added)
# Update TASK_STATUS.md
echo "- [x] PROCESS-20251001-001: Route Extraction Protocol (Oct 2, 2025)" >> TASK_STATUS.md
```

### Announce to Team
```markdown
**Subject:** New Route Extraction Protocol Available

Team,

We've created a comprehensive Route Extraction Protocol to prevent incidents like HOTFIX-20251001-001.

📖 **Document:** docs/ROUTE-EXTRACTION-PROTOCOL.md

**Key Features:**
- Pre-extraction checklist (25+ items)
- Step-by-step extraction process
- Testing requirements (unit + integration + template)
- Safe deployment protocol
- Emergency rollback procedures
- Real case studies (HOTFIX-20251001-001, TASK-001)

**When to Use:**
Use this protocol for ANY route extraction from main.py to modular routers.

**Next Steps:**
1. Review the protocol (15-20 min read)
2. Use for next route extraction
3. Provide feedback for v1.1

Thanks!
```

---

## Continuous Improvement

### Quarterly Review Schedule

**When:** First week of each quarter (Jan, Apr, Jul, Oct)

**Review Checklist:**
- [ ] Has protocol been followed in recent extractions?
- [ ] Any incidents despite following protocol?
- [ ] New lessons learned to incorporate?
- [ ] Team feedback received?
- [ ] Industry best practices changed?
- [ ] Update version number if changes made

---

**Plan Created:** October 2, 2025
**Plan Version:** 1.0
**Estimated Completion:** October 2, 2025 (same day)
**Status:** 🟢 READY FOR EXECUTION
