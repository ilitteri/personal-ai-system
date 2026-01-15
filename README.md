# Personal AI System

A lightweight file-based organization system that gives AI agents persistent memory across conversations.

## Quick Start

1. Clone to `~/Personal`:
   ```bash
   git clone https://github.com/ilitteri/personal-ai-system.git ~/Personal
   ```

2. Run setup:
   ```bash
   cd ~/Personal
   make setup
   ```

3. Reload shell and use in any project:
   ```bash
   source ~/.zshrc  # or open new terminal
   cd your-project
   claudio
   ```

## What Happens

1. Agent reads global `CLAUDE.md` (symlinked to all projects)
2. Agent finds/creates context in `~/Personal/contexts/{org}-{repo}.md`
3. Agent greets: "CLAUDE.md loaded. Standing rules active. Context loaded: project-name."
4. Context persists across sessions
5. All clones of same repo share context (uses git remote)

## Structure

```
Personal/
├── CLAUDE.md        # Global rules, symlinked to projects
├── binnacle.md      # Conversation history for Personal/
├── decisions.md     # Significant choices and reasoning
├── ideas.md         # Capture → review later
├── todos.md         # Prioritized actions
├── wip.md           # Active parallel work
├── prompts.md       # Reusable prompts
├── learnings.md     # Solved problems
└── contexts/        # Per-project state (auto-managed)
    └── _template.md
```

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Global rules symlinked everywhere. Customize with your rules. |
| `binnacle.md` | Ship's log for Personal/. Agents update before ending. |
| `decisions.md` | Log choices with reasoning. |
| `ideas.md` | Quick capture. Review periodically. |
| `todos.md` | Prioritized tasks (High/Medium/Low). |
| `wip.md` | Active parallel work across projects. |
| `prompts.md` | Reusable prompts. Copy-paste. |
| `learnings.md` | Solved problems. Search before debugging. |
| `contexts/` | Per-project state, auto-managed. |

## Key Features

- **Workstream tracking:** Multiple features per project, inferred from git branch
- **Context persistence:** Survives sessions, agent maintains it
- **Global rules:** Update once, applies everywhere via symlink

## Customization

1. Edit `CLAUDE.md` — add your standing rules
2. Edit `prompts.md` — add your common prompts
3. Edit `contexts/_template.md` — customize project context structure

## License

Dual-licensed under MIT and Apache 2.0. See LICENSE-MIT and LICENSE-APACHE.
