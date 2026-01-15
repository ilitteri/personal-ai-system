# Project Rules

When starting a conversation, confirm you've read this by saying:

> "CLAUDE.md loaded. Standing rules active. [Context status]. [Workstream status]."

Where context status is one of:
- "Context loaded: {project-name}" — if context file exists
- "New context created: {project-name}" — if you created one
- "Using binnacle" — if in ~/Personal/

Where workstream status is one of:
- "Focus: {workstream-name}" — if inferred from branch or only one active
- "Active workstreams: {list}" — if multiple and couldn't infer, then ask which one
- Omit if no workstreams defined yet

---

## Context Management

**At conversation start:**
1. Determine project identity:
   - If git repo: extract org/repo from remote (e.g., `org/repo` → `org-repo`)
   - If not git: use directory name
2. Look for `~/Personal/contexts/{project-identity}.md`
3. If exists: read it
4. If missing: create from `~/Personal/contexts/_template.md`
5. Exception: if in `~/Personal/`, use `binnacle.md` instead

**Workstream detection:**
1. Check the Active Workstreams section in context file
2. Get current git branch name
3. Match branch against workstream names (branch should contain workstream name)
4. If single match: that's the current focus
5. If no match or multiple active: list them and ask user which one
6. Common branch patterns: `feature/workstream-description`, `workstream/thing`, `fix/workstream-bug`

**During conversation:**
- Update context file after significant changes (decisions, completed milestones, direction changes)
- Update the relevant workstream's status when progress is made

**Before ending:**
- Update context file with current state, session summary, and notes for next session
- Update workstream status if changed

---

## Standing Rules

These apply to ALL work. Customize this section with your own rules.

### Git & Commits

- Do NOT add yourself as co-author of git commits
- Do NOT commit binary files
- Always run linter, formatter, and build check (if applicable) before committing

### CI & Quality

- If the project has CI workflows, understand them and run relevant checks locally before creating a PR

### Code Reviews

<!-- Add your code review rules here -->

### Code Sources & IP

<!-- Add restricted/allowed code sources here -->
<!-- Example:
**Restricted (reference only, no code reuse):**
- https://github.com/some-org/some-repo

**Allowed:**
- https://github.com/your-org/
-->

### Starting New Work

When starting a new project, feature, or documentation:
1. Ask the user for sources/references to learn from before beginning
2. Enter plan mode and write the plan to a markdown file (no permission needed)
3. Wait for user approval before implementing

### Context

Before starting work:
- Explore the project structure
- Identify and read relevant documentation, wherever it lives
- If in `~/Personal/`, read `binnacle.md` and `README.md` first
- If unsure where docs are, ask
