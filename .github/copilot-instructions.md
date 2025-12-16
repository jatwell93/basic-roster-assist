# GitHub Copilot Instructions for Roster Application

## Project Overview

This is a **Ruby on Rails** roster management application for Australian hospitality businesses. It helps manage employee scheduling, time tracking, and compliance with Fair Work regulations.

**Key Features:**
- Employee roster management
- Time tracking and attendance
- Fair Work compliance (award interpretation)
- Budget tracking and labor cost management
- Reporting and analytics

## Tech Stack

- **Language**: Ruby 3.2+
- **Framework**: Rails 8.x
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS
- **Testing**: RSpec, FactoryBot
- **Authentication**: Devise
- **Authorization**: Pundit
- **CI/CD**: GitHub Actions

## Coding Guidelines

### Testing
- Always write tests for new features (TDD: Red → Green → Refactor)
- Use `bundle exec rspec` to run tests
- Use FactoryBot for test data
- Never create test issues in production DB

### Code Style
- Run `bundle exec rubocop -a` before committing
- Follow Rails conventions (CoC, MVC, REST)
- Keep controllers skinny, models fat
- Use Active Record, not raw SQL
- Add `--json` flag to all bd commands for programmatic use

### Git Workflow
- Always commit `.beads/issues.jsonl` with code changes
- Run `bd sync` at end of work sessions
- Work in feature branches, never main/master

## Issue Tracking with bd (beads)

**CRITICAL**: This project uses **bd (beads)** for ALL task tracking. Do NOT create markdown TODO lists.

### Essential Commands

```bash
# Find work
bd ready --json                    # Unblocked issues
bd stale --days 30 --json          # Forgotten issues

# Create and manage
bd create "Title" -t bug|feature|task -p 0-4 --json
bd create "Subtask" --parent <epic-id> --json  # Hierarchical subtask
bd update <id> --status in_progress --json
bd close <id> --reason "Done" --json

# Search
bd list --status open --priority 1 --json
bd show <id> --json

# Sync (CRITICAL at end of session!)
bd sync  # Force immediate export/commit/push
```

### Workflow

1. **Check ready work**: `bd ready --json`
2. **Claim task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** `bd create "Found bug" -p 1 --deps discovered-from:<parent-id> --json`
5. **Complete**: `bd close <id> --reason "Done" --json`
6. **Sync**: `bd sync` (flushes changes to git immediately)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

## Project Structure

```
app/
├── models/           # Business logic, validation, associations
├── controllers/      # Request handling, coordination
├── views/            # ERB templates
├── services/         # Business operations (multi-step workflows)
├── mailers/          # Email composition
└── jobs/             # Active Job classes

config/
├── routes.rb         # Route definitions
├── database.yml      # DB configuration
└── environments/     # Environment-specific settings

db/
├── migrate/          # Schema migrations
└── seeds.rb          # Seed data

spec/
├── models/           # Model tests
├── controllers/      # Controller tests
├── services/         # Service tests
└── factories/        # FactoryBot factories

.beads/
├── beads.db          # SQLite database (DO NOT COMMIT)
└── issues.jsonl      # Git-synced issue storage
```

## CLI Help

Run `bd <command> --help` to see all available flags for any command.
For example: `bd create --help` shows `--parent`, `--deps`, `--assignee`, etc.

## Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Run `bd sync` at end of sessions
- ✅ Write tests before code (TDD)
- ✅ Run `bundle exec rubocop -a` before committing
- ✅ Run `bd <cmd> --help` to discover available flags
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT commit `.beads/beads.db` (JSONL only)
- ❌ Do NOT skip tests or commit untested code
- ❌ Do NOT hardcode secrets, APIs, or config

---

**For detailed workflows and Rails-specific guidelines, see [AGENTS.md](../AGENTS.md)**
