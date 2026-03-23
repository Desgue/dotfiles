---
name: my-skill                        # Slash command name (default: directory name)
description: What it does              # Helps Claude decide when to use it
argument-hint: [arg1] [arg2]          # Shown in autocomplete
disable-model-invocation: false       # true = only user can invoke via slash command
user-invocable: true                  # false = only Claude can invoke (background knowledge)
allowed-tools: Read, Grep, Glob      # Restrict available tools
model: claude-opus-4-6               # Override model for this skill
effort: high                          # low | medium | high | max
context: fork                         # Run in isolated subagent
agent: Explore                        # Subagent type when context: fork
---

## Instructions

Your markdown instructions here...

## Arguments

- `$ARGUMENTS` — all args passed to the command
- `$ARGUMENTS[0]` or `$0` — first arg
- `$ARGUMENTS[1]` or `$1` — second arg

## Shell Injection (runs before Claude sees the prompt)

Current branch: !`git branch --show-current`

## Skill Directory Reference

Run: bash ${CLAUDE_SKILL_DIR}/scripts/helper.sh

## Supporting Files

Reference other files in the skill directory with markdown links:
- See [checklist.md](checklist.md)
- See [examples/](examples/)

## Directory Structure

```
my-skill/
├── SKILL.md              # Required — main instructions
├── reference.md          # Optional — lazy-loaded when referenced
└── scripts/
    └── helper.sh         # Optional
```
