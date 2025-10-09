# Task Workspace: PROCESS-20251001-001
## Route Extraction Protocol Documentation

**Task ID:** PROCESS-20251001-001
**Title:** Route Extraction Protocol - Formalize Safe Extraction Process
**Priority:** HIGH
**Phase:** 0 (Hotfix Prevention)
**Estimated Effort:** 1 week (can be completed in 1 day)
**Started:** October 2, 2025
**Branch:** `process/route-extraction-protocol-20251001`

---

## Quick Summary

Create comprehensive documentation (`docs/ROUTE-EXTRACTION-PROTOCOL.md`) that formalizes the safe route extraction process to prevent future incidents like HOTFIX-20251001-001.

**Impact:** Prevents production incidents, reduces deployment risk, standardizes refactoring process.

---

## Workspace Files

```
.claude/workspace/PROCESS-20251001-001/
├── README.md                                    # This file
├── atomic-plan-PROCESS-20251001-001.md          # Detailed execution plan
├── checklist-PROCESS-20251001-001.md            # Execution checklist
├── success-criteria.md                          # Success criteria and metrics
└── notes.md                                     # Session notes and observations
```

---

## Quick Start

### 1. Review Plan
```bash
cat atomic-plan-PROCESS-20251001-001.md
```

**Key sections:**
- Executive Summary
- Success Criteria (5 primary)
- 5 Execution Phases
- Risk Assessment
- Time Estimates (6-7 hours total)

### 2. Start Work Session
```bash
# Create branch
git checkout -b process/route-extraction-protocol-20251001

# Verify clean working directory
git status

# Start timer
echo "Started: $(date)" >> notes.md
```

### 3. Track Progress
```bash
# Check completed items
grep "\[x\]" checklist-PROCESS-20251001-001.md | wc -l  # Completed items
grep "\[ \]" checklist-PROCESS-20251001-001.md | wc -l  # Remaining items

# Calculate progress percentage
TOTAL=$(grep -c "^- \[ \]" checklist-PROCESS-20251001-001.md)
DONE=$(grep -c "^- \[x\]" checklist-PROCESS-20251001-001.md)
echo "Progress: $DONE / $TOTAL ($(( DONE * 100 / TOTAL ))%)"
```

### 4. After Completion
```bash
# Final verification
bash verify_protocol.sh

# Update task status (when task added to tasks.csv)
# sed -i '' "s/PROCESS-20251001-001,\([^,]*\),pending,/PROCESS-20251001-001,\1,completed,/" tasks.csv

# Document completion
echo "Completed: $(date)" >> notes.md
echo "Total time: [X] hours" >> notes.md

# Archive workspace
# mv .claude/workspace/PROCESS-20251001-001 .claude/workspace/archive/PROCESS-20251001-001-$(date +%Y%m%d)
```

---

## Task Context

### Origin
This task was created in response to **HOTFIX-20251001-001**, a production incident on October 1, 2025, where the quotes list page returned 500 errors for 4-6 hours due to incomplete route extraction.

### Root Cause
When extracting routes from `main.py` to `app/routes/quotes.py` (TASK-002), 85 lines of data processing logic were left in `main.py` but not extracted to the router. The router returned raw `Quote` database objects, but the template expected processed data with calculated fields (`total_area`, `price_per_m2`, `items_count`, `sample_items`).

### Prevention Goal
This protocol ensures ALL future route extractions include proper data processing extraction, template compatibility verification, and gradual rollout with verification.

---

## Key Deliverables

### Primary Deliverable
- ✅ **docs/ROUTE-EXTRACTION-PROTOCOL.md** (500+ lines)

### Required Sections
1. Overview (purpose, background, philosophy)
2. When to Use This Protocol (required/optional situations)
3. Pre-Extraction Checklist (7 sub-sections, 25+ items)
4. Extraction Steps (7 phases with examples)
5. Testing Requirements (unit, integration, template)
6. Deployment Protocol (test → production)
7. Rollback Plan (emergency procedures)
8. Case Studies (HOTFIX-20251001-001, TASK-001)
9. Quick Reference (1-page checklists)

### Integration Points
- Reference in `CLAUDE.md`
- Link from `TASK_QUICKSTART.md`
- Integration with development workflow

---

## Success Criteria (Top 5)

1. ✅ **Documentation Complete** - All 9 sections with 500+ lines
2. ✅ **Actionable Checklists** - 25+ checklist items across all sections
3. ✅ **Real Examples** - HOTFIX-20251001-001 and TASK-001 case studies
4. ✅ **Workflow Integration** - Referenced in CLAUDE.md and task docs
5. ✅ **Team Review** - PR created with comprehensive description

**Full criteria:** See `success-criteria.md`

---

## Time Estimates

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Preparation** | 30 min | Setup, research, planning |
| **Implementation** | 3-4 hours | Write all 9 sections |
| **Integration** | 1 hour | Update project docs |
| **Documentation** | 30 min | Quality assurance |
| **Review** | 30 min | Final verification |
| **TOTAL** | **6-7 hours** | ~1 work day |

---

## Dependencies

### Required Reading
- ✅ `HOTFIX-20251001-RCA.md` - Root cause analysis
- ✅ `TASK-012-ROLLBACK-REPORT.md` - Rollback incident
- ✅ `app/routes/quotes.py` - Router implementation
- ✅ `app/presenters/quote_presenter.py` - Presenter pattern fix

### Successful Extraction Examples
- ✅ `app/routes/auth.py` (TASK-001) - Clean extraction with dependencies
- ✅ `app/routes/work_orders.py` (TASK-003) - Complex extraction with services
- ✅ `app/routes/materials.py` (TASK-003) - Router with CSV operations

### Anti-Pattern Examples
- ❌ TASK-002 initial implementation - Missing data processing
- ❌ TASK-012 attempted cleanup - Premature duplicate removal

---

## Risk Assessment

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| Protocol too generic | MEDIUM | 40% | Use concrete examples from HOTFIX-20251001-001 |
| Not followed by team | HIGH | 60% | Integrate into workflow, get buy-in |
| Becomes outdated | MEDIUM | 50% | Schedule quarterly reviews |
| Too complex to use | LOW | 20% | Include quick-reference checklists |

**Overall Risk:** MEDIUM (manageable with proper execution)

---

## Development Workflow

### Atomic Commits Strategy

Each major section gets its own commit:

```bash
# Example commit sequence
git commit -m "docs(protocol): create route extraction protocol skeleton"
git commit -m "docs(protocol): add overview and usage guidance"
git commit -m "docs(protocol): add comprehensive pre-extraction checklist"
git commit -m "docs(protocol): add detailed extraction steps with examples"
git commit -m "docs(protocol): add testing requirements"
git commit -m "docs(protocol): add deployment protocol"
git commit -m "docs(protocol): add case studies and quick reference"
git commit -m "docs(protocol): integrate with project documentation"
git commit -m "docs(protocol): complete route extraction protocol v1.0"
```

**Total expected commits:** 8-10

### Test Checkpoints

After each phase:
```bash
# Verify section exists
grep "^## [0-9]. [Section Name]" docs/ROUTE-EXTRACTION-PROTOCOL.md

# Check word count
wc -w docs/ROUTE-EXTRACTION-PROTOCOL.md

# Verify code examples
grep -c '```' docs/ROUTE-EXTRACTION-PROTOCOL.md

# Test Python syntax (if applicable)
# Test bash commands (if applicable)
```

---

## Rollback Procedures

### Full Rollback (Emergency)
```bash
# If protocol has critical errors
git checkout main
git branch -D process/route-extraction-protocol-20251001
rm -rf .claude/workspace/PROCESS-20251001-001

# Restart from beginning
```

### Partial Rollback (Fix Section)
```bash
# If one section needs rewriting
git log --oneline docs/ROUTE-EXTRACTION-PROTOCOL.md
git checkout [COMMIT_HASH] -- docs/ROUTE-EXTRACTION-PROTOCOL.md

# Re-implement section
nano docs/ROUTE-EXTRACTION-PROTOCOL.md
git commit -m "fix(protocol): rewrite [section] with corrections"
```

---

## Quality Assurance

### Pre-Commit Checks
```bash
# Before each commit
- [ ] Code examples tested
- [ ] Bash commands verified
- [ ] No placeholders (TODO, TBD, ...)
- [ ] No typos in critical sections
- [ ] Cross-references accurate
```

### Pre-PR Checks
```bash
# Before creating pull request
bash verify_protocol.sh  # Should pass all checks

# Manual verification
- [ ] Read entire document start to finish
- [ ] All 9 sections present
- [ ] Line count: 500+
- [ ] Code examples: 20+
- [ ] Checklist items: 25+
- [ ] Case studies: 2
```

---

## Post-Completion Actions

### Immediate (Day 1)
- [ ] Create pull request
- [ ] Update TASK_STATUS.md
- [ ] Announce protocol to team (if applicable)
- [ ] Archive workspace

### Short-term (Week 1)
- [ ] Incorporate review feedback
- [ ] Use protocol for next extraction (if applicable)
- [ ] Document any issues or improvements needed

### Long-term (Month 1)
- [ ] Verify no extraction incidents in 30 days
- [ ] Collect team feedback
- [ ] Plan v1.1 improvements (if needed)

---

## Related Tasks

### Prerequisites (Completed)
- ✅ TASK-001: Auth routes extraction (successful)
- ✅ TASK-002: Quote routes extraction (initial issue)
- ✅ TASK-003: Work orders and materials extraction (successful)
- ✅ HOTFIX-20251001-001: Router data processing fix
- ✅ HOTFIX-20251001-002: Integration tests

### Parallel Tasks
- 🔲 TASK-004: CSV test complexity reduction
- 🔲 TASK-005: Service interfaces (DIP)

### Follow-up Tasks
- 🔲 DEVOPS-20251001-001: Docker build improvements
- 🔲 Future route extractions (use this protocol)

---

## Useful Commands

### Progress Tracking
```bash
# View plan
less atomic-plan-PROCESS-20251001-001.md

# View checklist
cat checklist-PROCESS-20251001-001.md | grep "^##"

# Count completed items
grep -c "\[x\]" checklist-PROCESS-20251001-001.md

# Session notes
tail -f notes.md
```

### Git Operations
```bash
# View commits on this branch
git log --oneline main..HEAD

# View diff
git diff main...HEAD

# Check branch status
git status --short

# View remote branch
git ls-remote origin process/route-extraction-protocol-20251001
```

### Document Verification
```bash
# Quick stats
wc -l docs/ROUTE-EXTRACTION-PROTOCOL.md
wc -w docs/ROUTE-EXTRACTION-PROTOCOL.md
grep -c "^##" docs/ROUTE-EXTRACTION-PROTOCOL.md

# Find all checklists
grep "^- \[ \]" docs/ROUTE-EXTRACTION-PROTOCOL.md | wc -l

# Find code examples
grep -c '```' docs/ROUTE-EXTRACTION-PROTOCOL.md
```

---

## Notes and Observations

### Session Notes
Use `notes.md` for:
- Time tracking (start/stop times)
- Blockers encountered
- Questions raised
- Decisions made
- Lessons learned
- Improvements for next time

### Example Entry
```markdown
## Session 1: October 2, 2025

**Time:** 09:00 - 12:30 (3.5 hours)

**Completed:**
- Phase 1: Preparation (30 min)
- Phase 2: Implementation - Sections 1-4 (3 hours)

**Observations:**
- Pre-extraction checklist took longer than expected (45 min vs 30 min)
- Code examples needed more testing than planned
- Found additional anti-patterns to document

**Next Session:**
- Complete sections 5-9
- Integration phase
- Final review

**Blockers:** None
```

---

## Support and Help

### If Stuck
1. Re-read atomic plan section for current phase
2. Check success criteria for requirements
3. Review HOTFIX-20251001-RCA.md for context
4. Look at successful extraction examples (TASK-001, TASK-003)
5. Document blocker in notes.md

### Questions to Ask
- Is this section actionable?
- Can someone execute this without my help?
- Is there a concrete example?
- Are all commands tested?
- Does this prevent the HOTFIX-20251001-001 incident?

---

## Completion Checklist

**Task is complete when:**

```
[ ] All sections written (9/9)
[ ] All checklists complete (25+ items)
[ ] All code examples tested (20+)
[ ] All bash commands verified (10+)
[ ] Case studies documented (2)
[ ] Integration complete (CLAUDE.md updated)
[ ] verify_protocol.sh passes
[ ] Pull request created
[ ] Task status updated
[ ] Workspace archived
```

---

**Workspace Created:** October 2, 2025
**Last Updated:** October 2, 2025
**Status:** 🟢 READY FOR EXECUTION

**Ready to start?** Run:
```bash
cat atomic-plan-PROCESS-20251001-001.md | less
git checkout -b process/route-extraction-protocol-20251001
```

**Good luck!** 🚀
