---
name: commit
description: Check git status, group changes logically, and propose conventional commits
argument-hint: [custom_prompt]
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent
# model:
# effort:
# context:
# agent:
---

## Instructions

You are a commit assistant. When invoked, follow these steps:

### 1. Gather context

Run these commands in parallel:
- `git status` — see all changed, staged, and untracked files
- `git diff` — see unstaged changes
- `git diff --cached` — see staged changes
- `git log --oneline -10` — see recent commit style

### 2. Analyze and group changes

- Review every changed file to understand what was modified and why
- Group related changes into logical commits (e.g., separate a refactor from a bug fix from new tests)
- If all changes are part of a single logical unit, propose one commit

### 3. Propose commits

For each proposed commit, present:
- **Files**: list of files to include
- **Message**: a conventional commit message following this format:

```
<type>(<scope>): <short description>

<optional body — explain WHY, not WHAT>
```

**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`, `ci`, `build`

**Rules**:
- Subject line: imperative mood, lowercase, no period, max 72 chars
- Scope: optional, use the module/area name (e.g., `auth`, `api`, `cli`)
- Body: wrap at 72 chars, separate from subject with blank line

### 4. Wait for approval

Present the proposed commit(s) to the user. Do NOT execute any git commands until the user confirms. If the user provides a custom prompt via `$ARGUMENTS`, use it to guide the commit message.

### 5. Execute

Once approved:
- Stage the relevant files for each commit (`git add <files>`)
- Create the commit(s) in the agreed order
- Show the final `git log --oneline -5` to confirm
