# /generate-command Usage Examples

Complete guide to using the `/generate-command` system for creating new slash commands and AI agents.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Example 1: Simple Utility Command](#example-1-simple-utility-command)
3. [Example 2: Agent-Based Analysis Command](#example-2-agent-based-analysis-command)
4. [Example 3: Workspace Management Command](#example-3-workspace-management-command)
5. [Example 4: Complex Workflow Command](#example-4-complex-workflow-command)
6. [Tips & Best Practices](#tips--best-practices)

---

## Quick Start

### Basic Invocation

```bash
/generate-command
```

This launches the interactive wizard which guides you through:
1. Defining command purpose and complexity
2. Selecting tools and parameters
3. Reviewing generated structure
4. Validating and testing output

### With Pre-specified Name

```bash
/generate-command my-command-name
```

The wizard still runs but uses your provided name instead of asking for it.

---

## Example 1: Simple Utility Command

### Scenario
Create a command that shows git branch status with clean formatting.

### Wizard Interaction

```
/generate-command branch-status

🎯 What is the primary purpose of your new command?
👉 [6] Utility

⚙️ What is the complexity level of your command?
👉 [1] Simple

🤖 Does your command need a specialized AI agent?
👉 no

🛠️ Which tools will your command use?
👉 4 (Bash only)

📝 What parameters does your command accept?
👉 [Enter] (none - no parameters)

📊 Where should your command output its results?
👉 [1] Console only

🔗 Does your command integrate with existing workflows?
👉 Works with git repositories, displays branch info with status
```

### Generated Files

```
✅ .claude/commands/branch-status.md
✅ .claude/tests/test_branch_status_scaffold.sh
✅ .claude/docs/examples/branch-status-example.md
✅ Documentation updated
```

### Usage After Generation

```bash
# Test the command
/branch-status

# Expected output:
# 📊 Git Branch Status
# ━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Current: main
# Branches: 8
#   ✓ main (clean)
#   ✓ feature/new-api (2 commits ahead)
#   ! hotfix/urgent (uncommitted changes)
```

### Time to Create
**~5 minutes** (including testing)

---

## Example 2: Agent-Based Analysis Command

### Scenario
Create a command that analyzes project dependencies for security vulnerabilities and licensing issues.

### Wizard Interaction

```
/generate-command dependency-audit

🎯 What is the primary purpose of your new command?
👉 [2] Analysis

⚙️ What is the complexity level of your command?
👉 [3] Complex

🤖 Does your command need a specialized AI agent?
👉 yes

🛠️ Which tools will your command use?
👉 1,4,5,7 (Read, Bash, Glob, Task)

📝 What parameters does your command accept?
👉 [scope] - Optional: package|dev|all (default: all)

📊 Where should your command output its results?
👉 [4] Both console and files
📁 docs/dependency-audits/audit-{timestamp}.md

🔗 Does your command integrate with existing workflows?
👉 Run after npm install or package updates. Integrates with /code-review for security analysis.
```

### Agent Configuration Prompts

The wizard then asks additional questions for the agent:

```
🤖 Agent Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Agent Name: dependency-audit-agent

Agent Role: Dependency Security Auditor

What should the agent analyze?
👉 Package versions, known vulnerabilities (CVEs), license compatibility, dependency tree depth, outdated packages

What analysis framework should it use?
👉 OWASP Dependency Check methodology, CVE databases, npm audit output, license classification

What model should it use?
👉 [1] sonnet (fast, recommended for most analysis)

What color represents this agent?
👉 orange (security-related)
```

### Generated Files

```
✅ .claude/commands/dependency-audit.md
✅ .claude/agents/dependency-audit-agent.md
✅ .claude/tests/test_dependency_audit_scaffold.sh
✅ .claude/docs/examples/dependency-audit-example.md
✅ Documentation updated
```

### Generated Command Structure

**`.claude/commands/dependency-audit.md`**:
- Pre-analysis: Detects package manager, reads package files
- Agent invocation: Calls @dependency-audit-agent with context
- Post-processing: Generates report, creates action items
- Integration hooks: Links to /code-review, task creation

**`.claude/agents/dependency-audit-agent.md`**:
- Core responsibilities: Vulnerability detection, license analysis, version recommendations
- 5-step execution process
- Template system for report generation
- Quality checks for completeness

### Usage After Generation

```bash
# Full audit
/dependency-audit

# Scope to production packages only
/dependency-audit package

# Scope to dev dependencies
/dependency-audit dev
```

### Example Output

```
🔍 Dependency Audit Report
Generated: 2025-10-13 14:30:00

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Risk: MEDIUM
Vulnerabilities Found: 3
License Issues: 1
Outdated Packages: 12

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚨 Critical Issues:

1. lodash@4.17.15 (CVE-2021-23337)
   Severity: HIGH
   Fix: Upgrade to 4.17.21+

2. moment@2.24.0 (CVE-2022-31129)
   Severity: MEDIUM
   Fix: Replace with date-fns or upgrade

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Full Report: docs/dependency-audits/audit-20251013-143000.md

💡 Next Steps:
   1. Review critical vulnerabilities
   2. Run: npm update lodash moment
   3. Test after updates
```

### Time to Create
**~15 minutes** (including agent configuration and testing)

---

## Example 3: Workspace Management Command

### Scenario
Create a command that clones a workspace with all its files for experimentation.

### Wizard Interaction

```
/generate-command clone-workspace

🎯 What is the primary purpose of your new command?
👉 [5] Management

⚙️ What is the complexity level of your command?
👉 [2] Medium

🤖 Does your command need a specialized AI agent?
👉 no

🛠️ Which tools will your command use?
👉 1,2,4 (Read, Write, Bash)

📝 What parameters does your command accept?
👉 TASK-ID [new-name] - Required task ID, optional new name

📊 Where should your command output its results?
👉 [3] File modification (creates new workspace directory)

🔗 Does your command integrate with existing workflows?
👉 Works with /list-workspaces, /execute-task. Use before experimenting with alternate implementations.
```

### Generated Command Features

The wizard automatically includes:
- Workspace validation (checks if source exists)
- File copying with metadata preservation
- Checklist reset (marks all items as pending)
- Notes.md initialization with clone info
- tasks.csv update (if applicable)
- Git branch suggestion for cloned work

### Usage After Generation

```bash
# Clone with auto-generated name
/clone-workspace TASK-20251008-005

# Clone with custom name
/clone-workspace TASK-20251008-005 TASK-20251008-005-experiment
```

### Time to Create
**~8 minutes**

---

## Example 4: Complex Workflow Command

### Scenario
Create a pre-deployment validation command that checks code, tests, dependencies, and creates a deployment checklist.

### Wizard Interaction

```
/generate-command deploy-check

🎯 What is the primary purpose of your new command?
👉 [4] Orchestration

⚙️ What is the complexity level of your command?
👉 [3] Complex

🤖 Does your command need a specialized AI agent?
👉 no (uses SlashCommand to invoke other commands)

🛠️ Which tools will your command use?
👉 1,2,4,8 (Read, Write, Bash, SlashCommand)

📝 What parameters does your command accept?
👉 [environment] - Required: dev|staging|prod

📊 Where should your command output its results?
👉 [4] Both console and files
📁 docs/deployment-checks/check-{environment}-{timestamp}.md

🔗 Does your command integrate with existing workflows?
👉 Runs before CI/CD pipeline. Invokes /code-review, test runners, dependency checks. Creates deployment checklist.
```

### Generated Workflow

The command orchestrates multiple steps:

1. **Pre-flight checks**:
   - Git status (no uncommitted changes)
   - Branch verification (matches environment)
   - Clean build

2. **Code quality** (via `/code-review security`):
   - Security vulnerabilities
   - Critical issues only

3. **Test suite**:
   - Unit tests
   - Integration tests
   - E2E tests (staging/prod only)

4. **Dependency verification**:
   - No vulnerabilities
   - Licenses compliant

5. **Environment-specific checks**:
   - **Dev**: Linting passes
   - **Staging**: Performance benchmarks
   - **Prod**: All of the above + manual approval prompt

6. **Generate checklist**:
   - Markdown checklist file
   - Status summary
   - Approval signatures

### Generated Files

```
✅ .claude/commands/deploy-check.md
✅ .claude/tests/test_deploy_check_scaffold.sh
✅ .claude/docs/examples/deploy-check-example.md
✅ docs/deployment-checks/checklist-template.md (generated by command)
```

### Usage After Generation

```bash
# Development deployment check
/deploy-check dev

# Production deployment check (most stringent)
/deploy-check prod
```

### Example Output

```
🚀 Deployment Check: Production
Started: 2025-10-13 14:30:00

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Pre-flight Checks
   ✓ No uncommitted changes
   ✓ On branch: main
   ✓ Build successful

✅ Code Quality (/code-review security)
   ✓ No critical security issues
   ✓ Health score: 92/100

✅ Test Suite
   ✓ Unit tests: 148/148 passed
   ✓ Integration tests: 45/45 passed
   ✓ E2E tests: 12/12 passed

✅ Dependencies
   ✓ No vulnerabilities
   ✓ All licenses compliant

✅ Environment-Specific (Production)
   ✓ Performance benchmarks: PASS
   ✓ Load test: PASS
   ✓ Database migrations: Ready

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All checks passed!

📄 Deployment Checklist: docs/deployment-checks/check-prod-20251013-143000.md

⚠️  Manual Approval Required
   Reviewer: _______________
   Date: _______________

Ready to deploy? (yes/no): _
```

### Time to Create
**~20 minutes** (complex orchestration with multiple integration points)

---

## Tips & Best Practices

### Naming Commands

✅ **Good Names**:
- Action-oriented: `/deploy-check`, `/analyze-dependencies`
- Clear purpose: `/clone-workspace`, `/generate-report`
- Consistent casing: kebab-case (lowercase with hyphens)

❌ **Avoid**:
- Vague: `/do-stuff`, `/helper`
- Inconsistent: `/deployCheck`, `/Deploy_Check`
- Too long: `/analyze-dependencies-and-generate-comprehensive-report`

### Choosing Complexity

Use the **simplicity test**:
- **Simple**: Can you explain the logic in 1 sentence?
- **Medium**: Requires 2-3 coordinated steps?
- **Complex**: Needs decision-making or agent intelligence?

### Agent vs No Agent

**Create an agent when**:
- Analysis requires contextual understanding
- Multiple strategies must be evaluated
- Output quality depends on reasoning
- Task decomposition is non-trivial

**Skip the agent when**:
- Logic is deterministic
- Simple data transformation
- Direct tool invocation
- Clear input→output mapping

### Tool Selection

Common combinations:
- **Read + Bash**: Simple analysis or display
- **Read + Write + Bash**: File generation
- **Read + Edit**: File modification
- **All tools + Task**: Complex agent-based commands
- **Bash + SlashCommand**: Orchestration commands

### Documentation Quality

The wizard generates templates, but **enhance them**:
- Add real-world examples from actual usage
- Document edge cases discovered during testing
- Include troubleshooting for common errors
- Link to related commands and workflows

### Testing Generated Commands

Always run the test scaffold:

```bash
# Run generated tests
bash .claude/tests/test_YOUR_COMMAND_scaffold.sh

# Fix any failures before using
# Add functional tests for complex logic
```

### Iteration Strategy

**Start simple, then enhance**:

1. **V1**: Basic functionality, minimal features
2. **Test**: Use in real scenarios
3. **V2**: Add features based on usage
4. **Refine**: Improve error handling, edge cases
5. **Document**: Update examples with real usage

### Integration Planning

Think about **before/after** commands:
- What runs before this command?
- What uses this command's output?
- Which workflows include this command?
- How does it fit in the task lifecycle?

### Common Pitfalls

❌ **Over-engineering**: Don't create complex commands for simple tasks
❌ **Under-documenting**: Skipping examples makes commands hard to use
❌ **Ignoring tests**: Test scaffolds catch issues early
❌ **Tight coupling**: Commands should be loosely coupled when possible
❌ **Assuming context**: Always validate inputs and environment

---

## Wizard Tips

### Speeding Up the Wizard

For experienced users:
- Prepare answers beforehand
- Know which template you need
- Have example commands ready for reference
- Understand tool capabilities

### Learning from Examples

Before creating a new command:

```bash
# Study similar commands
ls .claude/commands/

# Read a few examples
cat .claude/commands/list-workspaces.md
cat .claude/commands/code-review.md

# Understand patterns
grep "^## " .claude/commands/*.md | sort | uniq -c
```

### When to Customize

After generation, consider customizing:
- Error messages (make them more specific)
- Examples (add real-world scenarios)
- Integration points (add missing workflows)
- Validation (add domain-specific checks)

---

## Success Checklist

After generating a command, verify:

- ✅ Command file has valid YAML frontmatter
- ✅ Test scaffold runs and passes
- ✅ Documentation is clear and complete
- ✅ Examples work as described
- ✅ Integration points are documented
- ✅ Error handling is comprehensive
- ✅ Command follows naming conventions
- ✅ Agent is properly configured (if applicable)

---

## Getting Help

If you encounter issues:

1. **Check test scaffold output** - It identifies common problems
2. **Validate YAML** - Use `yq` or online validators
3. **Review similar commands** - Find patterns in existing commands
4. **Regenerate** - Sometimes it's faster to start over
5. **Manual fixes** - Edit generated files directly

---

**Last Updated**: 2025-10-13
**System Version**: 1.0
**Examples Count**: 4 (simple, agent-based, management, complex)
