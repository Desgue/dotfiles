---
name: commit
description: Check git status, group changes logically, and propose conventional commits
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash(git *), Bash(gh *)
model: haiku
effort: medium
context: fork
agent: general-purpose
---

$ARGUMENTS

## Rules

1. NEVER CHAIN COMMANDS
2. NEVER USE BASH TO CAT OR ECHO TO WRITE COMMIT MESSAGES — pass messages directly via `git commit -m` so no human approval is needed
3. NEVER add Co-Authored-By or any authorship attribution to commit messages
4. DO NOT USE COMMANDS THAT NEED HUMAN APPROVAL

## Process

1. Run `git status`
2. List in memory the untracked files
3. List in memory the staged changes
4. List in memory the unstaged modifications
5. Run `git log --oneline -20` to read recent commit messages. Use this context to understand the codebase evolution, naming conventions, and commit style.
6. Group related files into logical units of work. List each group and its files only.
7. Order the groups by dependency — foundational changes first, dependent changes after.
8. For each group, in order, stage the files and commit following this exact structure:

<commit_format>
type(scope): imperative description (max 50 chars)

If multiple changes warrant it, add a bullet list body:

type(scope): imperative description (max 50 chars)

- change one
- change two
- change three

Default to a single-line commit when possible.
</commit_format>

Commit each group in order, do not ask permission.
