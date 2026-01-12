# AGENTS.md – Ruby on Rails Development Guide

**Version**: 1.2 | **Compatibility**: Claude, Cursor, Copilot, Cline, Aider, all AGENTS.md-compatible tools  
**Status**: Canonical guide for AI-assisted Rails development  
**Last Updated**: December 2025

---

## Table of Contents

1. [Compliance & Core Rules](#1-compliance--core-rules)
2. [Rails Development Standards](#2-rails-development-standards)
3. [Session Startup & Context](#3-session-startup--context)
4. [Project Structure & Memory Bank](#4-project-structure--memory-bank)
5. [State Machine](#5-state-machine)
6. [Task Management with Beads](#6-task-management-with-beads)
7. [Quality & Testing](#7-quality--testing)
8. [Security & Code Review](#8-security--code-review)
9. [Troubleshooting](#9-troubleshooting)

---

**⚠️ Note on Gems**: Gem-specific patterns (Devise, Sidekiq, RSpec, etc.) are in `gems.md`. Load that file when working with external gems to keep token usage efficient.

**⚠️ Note on Searching**: Use `ast-grep` for structural code changes, `ripgrep` for text search. See [Searching Guide](#searching--ast-grep-vs-ripgrep) below.

---

## 1. Compliance & Core Rules

### Startup Compliance (Output Every Session)

```
COMPLIANCE CONFIRMED: Reuse over creation | Rails conventions respected

⚠️  GIGO PREVENTION - User Responsibilities:
📋 Clear task objectives | 🔗 Historical context | 🎯 Success criteria
⚙️  Architectural constraints | 🎖️ You lead - clear input = excellent output

[Proceeding with Rails Guidelines + State Machine...]
```

### The Four Sacred Rules (Rails-Specific)

| Rule | Requirement | Validation |
|------|-------------|------------|
| ❌ **No new files without reuse analysis** | Search codebase, check existing models/services, provide justification | "Analyzed `app/models/X`, `app/services/Y`. Cannot extend because [reason]" |
| ❌ **No rewrites when refactoring possible** | Prefer incremental improvements to existing services/models | "Extending `User` model at line X rather than creating new model" |
| ❌ **No ignoring Rails conventions** | Follow CoC, MVC pattern, REST principles, Active Record patterns | "Follows Rails conventions from `config/` and existing patterns" |
| ❌ **No skipping tests** | TDD mandatory—red, green, refactor. Never commit without tests | "Red: wrote failing test \| Green: implemented \| Verified: exit code 0" |

### Non-Negotiables

- **Approval Gates**: No commits without explicit user approval
- **Sandbox First**: All work in feature branches, never main/master
- **Citations**: Always `app/path/file.rb:42` (single line) or `app/path/file.rb:42-58` (range)
- **No Mock Data**: Never fake/simulated data in production; test fixtures are OK
- **No Secrets**: Never hardcode API keys, passwords, or credentials
- **TDD Mandatory**: Tests written before production code
- **Code Quality**: Must pass `rubocop`, `bundle exec rails test`, and `ubs .` before commit
- **Task Tracking**: Use `bd` (Beads) for ALL work—no markdown TODOs

---

## 2. Rails Development Standards

### Core Rails Principles

#### Convention over Configuration (CoC)
Following Rails conventions reduces code. Always ask: "Does Rails already provide this?"

**Good**:
- Model: `app/models/user.rb` inheriting `ApplicationRecord`
- Controller: `app/controllers/users_controller.rb` with RESTful actions
- Migration: `db/migrate/TIMESTAMP_create_users.rb`

**Anti-Pattern**:
- Custom database layer bypassing Active Record
- Non-standard directory structures
- Controllers with multiple responsibilities

#### MVC Architecture

| Component | Responsibility | Anti-Pattern |
|-----------|-----------------|-------------|
| **Model** | Business logic, validation, associations, scopes | Business logic in controller |
| **Controller** | Request handling, coordination, response | Complex logic, direct DB queries |
| **View** | Presentation only, loops OK, complex logic NOT OK | Business logic in view |

#### RESTful Design

Actions correspond to HTTP verbs:

```ruby
GET    /users           → index (list all)
GET    /users/:id       → show (single resource)
GET    /users/new       → new (form)
POST   /users           → create (persist new)
GET    /users/:id/edit  → edit (form)
PATCH  /users/:id       → update (persist changes)
DELETE /users/:id       → destroy (delete)
```

**Rails generates routes automatically:**
```ruby
# config/routes.rb
resources :users  # Creates all 7 RESTful routes
```

#### Active Record Pattern

Models represent database tables:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :posts
  validates :email, presence: true, uniqueness: true
  
  scope :active, -> { where(archived: false) }
  scope :recent, -> { order(created_at: :desc) }
end
```

Never hand-write SQL; use Active Record chainable methods.

#### Fat Models, Skinny Controllers

**Good**:
```ruby
# Model: Business logic
class User < ApplicationRecord
  def activate!
    update(activated_at: Time.current)
    send_welcome_email
  end
end

# Controller: Coordination only
def update
  @user = User.find(params[:id])
  if @user.update(user_params)
    redirect_to @user, notice: 'Updated'
  else
    render :edit
  end
end
```

**Anti-Pattern**:
```ruby
# Controller with business logic
def activate_user
  User.find(params[:id]).update(activated_at: Time.current)
  UserMailer.welcome_email(user).deliver_later
  # Should be in model!
end
```

#### Single Responsibility Principle (SRP)

Each class/module should have one reason to change.

**Good**:
```ruby
# app/services/user_registration.rb
class UserRegistration
  def initialize(user_params)
    @user_params = user_params
  end
  
  def call
    user = User.create!(@user_params)
    send_confirmation_email(user)
    user
  end
  
  private
  
  def send_confirmation_email(user)
    UserMailer.confirm_email(user).deliver_later
  end
end
```

**Anti-Pattern**:
```ruby
# User model doing too much
class User < ApplicationRecord
  def register_and_email_and_notify_admin_and_log
    # Too many responsibilities!
  end
end
```

#### Dependency Injection

Pass dependencies as parameters, don't hardcode them:

```ruby
# Good: Dependency injected
class UserService
  def initialize(email_service: UserMailer)
    @email_service = email_service
  end
  
  def create_and_notify(params)
    user = User.create(params)
    @email_service.notify(user)
  end
end

# Usage
service = UserService.new(email_service: TestMailer)

# Testing
it 'sends email on create' do
  mailer = double(:mailer)
  service = UserService.new(email_service: mailer)
  expect(mailer).to receive(:notify)
  service.create_and_notify(params)
end
```

### Clean Code Rules

- **Intention-Revealing Names**: `active_users_count` not `x` or `get_users`
- **Single Responsibility**: Each method one clear purpose
- **Guard Clauses First**: Return early for edge cases
- **Symbolize Constants**: `STATUS = :active` not `"active"`
- **Input → Process → Return**: Clear structure
- **Fail with Specific Errors**: Raise custom exceptions, not generic errors
- **Comments Explain Why**: "Why" not "what" (code shows what)

**Good**:
```ruby
def activate_user(user)
  return user if user.active? # Guard clause: early return

  user.update(activated_at: Time.current)
  send_welcome_email(user)
  user
rescue StandardError => e
  Rails.logger.error("Activation failed: #{e.message}")
  raise ActivationError, "Could not activate user #{user.id}"
end
```

### Project Structure

Use codemap to when you need up-to-date structure of the project

```bash
codemap .                     # Project structure
codemap --deps                # How files connect
codemap --diff                # What changed vs main
codemap --diff --ref <branch> # Changes vs specific branch
```

## Required Usage

**BEFORE starting any task**, run `codemap .` first.

**ALWAYS run `codemap --deps` when:**
- User asks how something works
- Refactoring or moving code
- Tracing imports or dependencies

**ALWAYS run `codemap --diff` when:**
- Reviewing or summarizing changes
- Before committing code
- User asks what changed
- Use `--ref <branch>` when comparing against something other than main

---

## 3. Session Startup & Context

### Load Priority (Based on Task Complexity)

**Every Session (Mandatory)**:
1. Output compliance statement (Section 1)
2. Load README.md and AGENTS.md
3. Load relevant documentation (see below)
4. Identify environment: development/test/staging/production
5. **Check task priority**: `bd ready --json` (highest priority first)

**Quick Bug Fix** (30 min):
- [ ] Load relevant model/service/controller
- [ ] Understand failing test (if applicable)
- [ ] Load affected config/routes
- [ ] Check Beads: `bd show <id> --json`

**Standard Feature Work** (2-4 hours):
- [ ] Load README.md (project overview)
- [ ] Load current schema from `db/schema.rb`
- [ ] Load relevant models, services, controllers
- [ ] Load existing tests (same area) as reference
- [ ] Check Beads: `bd ready --json` (get priority order)

**Architecture/Refactoring** (4+ hours):
- [ ] Load all of above
- [ ] Load architecture documentation
- [ ] Load decision logs (if exists)
- [ ] Review existing patterns in codebase

**Gem-Specific Work**:
- [ ] Load `gems.md` when working with Devise, Sidekiq, RSpec, ActiveStorage, etc.

### Session Question Protocol

Before starting work, clarify:
1. **Task**: What is the clear objective?
2. **Scope**: Which models/controllers/services affected?
3. **Success**: What does "done" look like? (Acceptance criteria)
4. **Constraints**: Any architectural requirements or limitations?
5. **Context**: What related work exists? (PRs, issues, patterns)

---

## 4. Project Structure & Memory Bank

### Recommended Documentation Files

Create these in your Rails project root for reference:

```bash
root/
├── README.md                    # Project overview, setup, running tests (created)
├── AGENTS.md                    # This file 
├── gems.md                      # Gem patterns & best practices (load when needed)
├── .beads/
│   ├── README.md                # Beads quick reference (created)
│   └── beads.db                 # Issue database (git-tracked JSONL) (created)
├── openspec/
│   └── AGENTS.md                # OpenSpec instructions for agents (created)
├── docs/
│   ├── architecture.md          # System design, components, integrations (create when needed)
│   ├── database-schema.md       # Data model overview, key relationships (create when needed)
│   ├── api-conventions.md       # API standards, response formats (create when needed)
│   ├── testing-patterns.md      # How to write tests (fixtures, factories) (create when needed)
│   ├── deployment.md            # How to deploy (CI/CD, env vars) (create when needed)
│   ├── beads-READMED.md         # Set up for beads (created)
│   ├── TROUBLESHOOTING.md       # Trouble shooting for beads (created)
│   ├── SETUP.md                 # Initital setup (createed)
│   ├── bug-checker-ubs.md       # How to use the bug checker for hard to find bugs and before commits
│   └── decisions.md             # Architectural decision records (ADRs)(create when needed)
└── .env.example                 # Environment variables (no secrets!)
```

### Documentation Standards

**README.md** should include:
- What this project does
- Local setup (Ruby version, bundler, DB setup)
- How to run tests (`bundle exec rails test`)
- How to run server (`rails s`)
- Key architecture decisions
- Contributing guidelines (point to AGENTS.md)

**docs/architecture.md** should include:
- System components (models, services, background jobs)
- Key data flows (e.g., user signup flow)
- External integrations
- Performance considerations

**gems.md** should include:
- Setup instructions for major gems
- Common usage patterns
- When to load this file vs AGENTS.md

---

## 5. State Machine

### States: PLAN → BUILD → DIFF → QA → APPROVAL → APPLY → DOCS

```
PLAN [user approves] → BUILD → DIFF → QA [pass] → APPROVAL [user approves] → APPLY → DOCS → END
  ↑                    ↑_________↓________↓_____[fail/changes]__________________↓
  └──────────────────────────────────────────[major changes needed]───────────┘
```

### PLAN State

**In**: Task contract | **Out**: Implementation outline  
**Exit**: User approves (says "approved", "proceed", "looks good")

**Required Content**:
```markdown
## Plan: [Feature/Fix Name]

**Analysis**:
- Current: `app/models/user.rb` (User model with X attributes)
- Affected: `app/controllers/users_controller.rb`, `spec/models/user_spec.rb`
- Pattern: Extends existing `Validatable` concern (see `app/models/concerns/validatable.rb`)

**Reuse Strategy**:
- Extend `User` model with new validation
- Add scope to User for filtering
- Follow existing test pattern from `spec/models/post_spec.rb`

**Implementation Steps**:
1. Add validation to `User` model (line 42)
2. Add scope to filter users (line 58)
3. Write tests mirroring `spec/models/post_spec.rb`
4. Update controller filter logic

**Integration Points**:
- Users controller calls new scope: `User.active`
- No breaking API changes

**Tests**: Unit (validation, scope) | Integration (controller filter) | Manual (verification)

**Estimated Work**: 1-2 hours
```

**Exit**: User approves or provides feedback

### BUILD State

**In**: Approved plan | **Out**: Code changes (NOT APPLIED YET)  
**Actions**:
1. Create feature branch: `git checkout -b feature/description`
2. Update Beads: `bd update <id> --status in_progress --json`
3. Write tests (RED phase) before implementation
4. Implement code (GREEN phase) - If you discover new work during this process, **always create a new Beads issue** linked to the current task using `bd create "Discovered bug" --description="Details" -p 1 --deps discovered-from:bd-a1b2 --json`.
5. Run tests: `bundle exec rails test`
6. Run linter: `bundle exec rubocop -a`
7. **🚀 GOLDEN RULE**: Run `ubs --only=ruby,js,ts` before commit
   - Exit 0 = safe to commit
   - Exit >0 = fix bugs and re-run `ubs`
8. Generate diff (do NOT commit/push yet)

**TDD Phases**:

```ruby
# PHASE 1: RED (Failing test)
# spec/models/user_spec.rb
describe User do
  describe 'validations' do
    it 'validates email format' do
      user = User.new(email: 'invalid')
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include('must be valid')
    end
  end
end

# PHASE 2: GREEN (Implementation)
# app/models/user.rb
class User < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be valid' }
end

# Verify: bundle exec rails test (should now pass)
```
**UBS (Ultimate Bug Scanner) Integration**:

UBS stands for **"Ultimate Bug Scanner"**: Flags likely bugs early. Use before every commit.

**Quick Reference**:
```bash
ubs <changed-files>          # Specific files (< 1s) — RECOMMENDED
ubs $(git diff --name-only)  # Staged files
ubs --only=ruby,js app/      # Language filter (faster)
ubs .                        # Whole project (background task only)
```

**Output Format**:
```
⚠️  Category (N errors)
    file.rb:42:5 – Issue description
    💡 Suggested fix
Exit code: 0 (pass) or >0 (fix needed)
```

**Severity Levels**:
- **Critical**: null/undefined, injection, race conditions, resource leaks → Fix immediately
- **Important**: type issues, error handling, performance → Fix before merge
- **Contextual**: TODOs, console logs → Judgment call

**Fix Workflow**:
1. Read finding → understand issue
2. Navigate to `file:line:col`
3. Verify it's a real issue (not false positive)
4. Fix root cause (not symptom)
5. Re-run `ubs <file>` → confirm exit 0

**Exit**: Tests pass (`bundle exec rails test` → exit 0), linter clean, **UBS passed**, diff generated

### DIFF State

**In**: BUILD complete | **Out**: Proposed changes with rationale  
**Present**:
```markdown
## Proposed Changes

**Files**:
```
app/models/user.rb          |  5 +++
spec/models/user_spec.rb    | 20 +++++++++++
2 files, 25 insertions(+)
```

**Diff**:
[git diff output]

**Rationale**:
- Added email validation to User model per task requirements
- Tests follow existing pattern in `spec/models/post_spec.rb`
- No breaking changes to API

**Checks**:
- ✅ Tests: 145 passing
- ✅ Linter: clean
- ✅ UBS: passed (no critical/important issues)
```

### QA State

**In**: DIFF presented | **Out**: Test results | **Exit**: Tests pass OR user waiver  
**Execute**:
1. Run full test suite: `bundle exec rails test`
2. Run linter: `bundle exec rubocop`
3. Run UBS on all changes: `ubs $(git diff --name-only HEAD~1)`
4. Report results:

```markdown
## QA Results

**Tests**: ✅ PASS | Total: 145 | Duration: 12.3s
**Linter**: ✅ PASS | Errors: 0 | Warnings: 0
**UBS**: ✅ PASS | No critical/important findings

**Verdict**: ✅ Ready for APPROVAL
```

**Exit**: All checks pass OR user grants explicit waiver

### APPROVAL State (HUMAN GATE)

**In**: QA passed | **Out**: User decision  
**Present**:
```markdown
## Ready for Approval ✅

Code changes complete, tested, and scanned. Ready for merge.

**Summary**:
- Added email validation to User model
- 20 new tests, all passing
- No UBS issues (critical/important)
- No breaking changes

**Files Modified**:
- `app/models/user.rb` (+5 lines)
- `spec/models/user_spec.rb` (+20 lines)

**Checks**:
- ✅ Tests pass: 145/145
- ✅ Linter clean
- ✅ UBS passed
- ✅ Security reviewed: no secrets, validated input
- ✅ Follow Rails conventions

**Next**: Merge to main branch, deploy to staging

---

**Please review. Reply with**:
- "approved" | "looks good" → Merge to develop
- "change X" → Back to BUILD
- "revert" → Discard all
```

**Exit**: User approves explicitly

### APPLY State

**In**: User approved | **Out**: Changes applied/merged  
**Actions**:
1. Verify all tests pass one final time
2. Merge feature branch to main: `git merge --no-ff feature/description`
3. Verify merge successful
4. Update Beads: `bd close <id> --reason "Merged to develop" --json`
5. Sync Beads: `bd sync`
6. Report success

### DOCS State

**In**: APPLY succeeded | **Out**: Documentation updated  
**Create/Update** (only if applicable):
1. Update README.md if setup changed
2. Update docs/architecture.md if structure changed
3. Add decision to docs/decisions.md if architectural choice made
4. Document any new patterns used

---

## 6. Task Management with Beads

### Essential Beads Commands

Use `--json` flag for programmatic output. All commands:

```bash
# Check what to work on
bd ready --json                    # Unblocked, ready-to-start issues
bd stale --days 30 --json          # Forgotten issues (not updated in 30d)
bd list --status open --priority 0 --json  # All critical issues

# Create tasks (ALWAYS include --description)
bd create "Title" \
  --description="Detailed context and why this matters" \
  -t bug|feature|task \
  -p 0-4 \
  --json

# Manage workflow
bd show <id> --json                # View issue details
bd update <id> --status in_progress --json  # Claim work
bd close <id> --reason "Resolved" --json  # Mark complete
bd reopen <id> --json              # Revert close

# Search & filter
bd list --priority 1 --json        # High priority
bd list --status in_progress --json  # Your active work

# Sync to git (CRITICAL at end of session!)
bd sync                            # Force immediate export/commit/push
```

### Workflow: From Task to Commit

1. **Start session**: `bd ready --json` (get highest-priority unblocked work)
2. **Claim task**: `bd update <id> --status in_progress --json`
3. **Work**: Implement, test, UBS scan
4. **Discover bugs?** `bd create "Bug: X" --description="Found during implementation of <parent_id>" -t bug -p 1 --json`
5. **Finish**: `bd close <id> --reason "Fixed and merged" --json`
6. **Sync**: `bd sync` (pushes changes to git immediately)

### Priority Scale

| Level | Examples | Action |
|-------|----------|--------|
| **0 - Critical** | Security breach, data loss, broken CI, prod outage | Drop everything, fix now |
| **1 - High** | Major features, important bugs, blocking other work | Next task after current |
| **2 - Medium** | Default, nice-to-have features, non-urgent fixes | Normal work priority |
| **3 - Low** | Polish, optimization, technical debt exploration | When spare capacity |
| **4 - Backlog** | Future ideas, vague requests, research | No time commitment |

### Important Rules

- ✅ Use `bd` for ALL task tracking (no markdown TODOs)
- ✅ Always include `--description` when creating issues (context matters!)
- ✅ Use `--json` flag for all commands (programmatic consistency)
- ✅ Run `bd sync` at end of every session
- ✅ Test locally with `BEADS_DB=/tmp/test.db` before production use
- ✅ Store AI planning docs in `history/` directory
- ✅ Run `bd <cmd> --help` to discover available flags
- ✅ Commit `.beads/issues.jsonl` together with code changes
- ❌ Do NOT commit `.beads/beads.db` directly (beads handles git)
- ❌ Do NOT create test data in production database
- ❌ Do NOT close tasks without updating status in code first
- ❌ Do NOT clutter repo root with planning documents

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### Managing AI-Generated Planning Documents

AI assistants often create planning and design documents during development:
- PLAN.md, IMPLEMENTATION.md, ARCHITECTURE.md
- DESIGN.md, CODEBASE_SUMMARY.md, INTEGRATION_PLAN.md
- TESTING_GUIDE.md, TECHNICAL_DESIGN.md, and similar files

**Best Practice: Use a dedicated directory for these ephemeral files**

**Recommended approach:**
- Create a `history/` directory in the project root
- Store ALL AI-generated planning/design docs in `history/`
- Keep the repository root clean and focused on permanent project files
- Only access `history/` when explicitly asked to review past planning

**Benefits:**
- ✅ Clean repository root
- ✅ Clear separation between ephemeral and permanent documentation
- ✅ Easy to exclude from version control if desired
- ✅ Preserves planning history for archeological research
- ✅ Reduces noise when browsing the project

---

## Searching – ast-grep vs ripgrep

**Use `ast-grep` when structure matters.** It parses code and matches AST nodes—results ignore comments/strings, understand syntax, and support **safe rewrites**.

- **Refactors/codemods**: Rename APIs, change import forms, rewrite call sites
- **Policy checks**: Enforce patterns repo-wide
- **Editor/automation**: LSP mode, JSON output

**Use `ripgrep` when text is enough.** Fastest way to grep literals/regex across files.

- **Recon**: Find strings, TODOs, log lines, config values
- **Pre-filter**: Narrow candidates before precise pass

**Quick Commands**:

```bash
# Find structured code (ignores comments/strings)
ast-grep run -l ruby -p 'User.where($X)' -r 'User.active' -U

# Quick textual hunt
rg -n 'TODO:' -t rb

# Combine: ripgrep for speed, ast-grep for precision
rg -l 'params\[:' app/ | xargs ast-grep run -l ruby -p 'params\[:\$A\]' -r 'params.permit(:$A)' -U
```

---

## 7. Quality & Testing

### Test-Driven Development (TDD) Mandatory

**Three-Phase Cycle**:

1. **Red**: Write test that fails
   ```ruby
   it 'sends welcome email when user created' do
     expect {
       User.create(email: 'test@example.com')
     }.to have_enqueued_job(UserMailer)
   end
   ```

2. **Green**: Implement minimal code to pass
   ```ruby
   class User < ApplicationRecord
     after_create :send_welcome_email
     
     private
     
     def send_welcome_email
       UserMailer.welcome(self).deliver_later
     end
   end
   ```

3. **Refactor**: Improve without changing behavior
   ```ruby
   class User < ApplicationRecord
     has_one :welcome_email_sent, dependent: :destroy
     after_create :queue_welcome_email
     
     private
     
     def queue_welcome_email
       WelcomeEmailJob.perform_later(id)
     end
   end
   ```

### Completion Checklist

Before marking task complete, run (all must pass):

```bash
# Run all tests
bundle exec rails test
# Expected: exit code 0

# Run linter with auto-fix
bundle exec rubocop -a
# Expected: exit code 0 or only minor warnings

# Check for security issues
bundle audit
# Expected: no vulnerabilities

# Scan for bugs (CRITICAL)
ubs $(git diff --name-only)
# Expected: exit code 0 (no critical/important issues)

# Check coverage (if using simplecov)
# Expected: >95% coverage for new code
```

---

## 8. Security & Code Review

### Security Checklist

**Before APPROVAL, verify**:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user input validated: `validates :email, presence: true`
- [ ] All user input encoded when displayed (Rails does this by default)
- [ ] No SQL injection: Use parameterized queries (`where(email: params[:email])`)
- [ ] Authentication required on sensitive endpoints
- [ ] Authorization verified (current_user can perform action?)
- [ ] Sensitive data logged appropriately (no passwords in logs)
- [ ] CSRF protection enabled (Rails default)
- [ ] Rate limiting on public endpoints (if applicable)

**Good**:
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
  
  def authorize_user!
    unless current_user == @user || current_user.admin?
      redirect_to root_path, alert: 'Not authorized'
    end
  end
end
```

**Anti-Pattern**:
```ruby
# DON'T DO THIS
def update
  sql = "UPDATE users SET email = '#{params[:email]}' WHERE id = #{params[:id]}"
  ActiveRecord::Base.connection.execute(sql)
end
```

### Code Review Gates

**Must pass before merge**:
1. ✅ Tests passing (`bundle exec rails test`)
2. ✅ Linter clean (`bundle exec rubocop`)
3. ✅ **UBS passed** (`ubs <changed-files>` → exit 0)
4. ✅ Security checklist passed
5. ✅ No hardcoded secrets
6. ✅ Follows Rails conventions
7. ✅ Comments explain "why", not "what"

---

## 9. Troubleshooting

### Common Issues

| Problem | Symptom | Solution |
|---------|---------|----------|
| **Test Failures** | `bundle exec rails test` returns non-zero | Read error message, check test expectations, verify test data setup (fixtures/factories) |
| **Linter Errors** | `bundle exec rubocop` fails | Run `bundle exec rubocop -a` to auto-fix, resolve remaining manually |
| **UBS False Positives** | UBS flags something that's not a bug | Check context, ignore if safe, document why in code comment |
| **Schema Mismatch** | "relation does not exist" error | Run `bundle exec rails db:migrate` to sync schema |
| **Dependency Issues** | "Gem not found" error | Run `bundle install`, verify `Gemfile.lock` committed |
| **Performance** | Endpoint slow | Use `rails panel` (Rack::MiniProfiler) to profile, check N+1 queries |
| **State Issues** | Tests pass individually, fail together | Check test isolation, use `before_each` hooks, avoid shared state |

### Agent Stuck Protocol

**Condition**: Same error three consecutive attempts

**Response**:
1. Diagnose: Root cause of error, not symptom
2. Load more context: Relevant models, services, existing patterns
3. Propose alternative: Different technical approach
4. Request help: Ask user for clarification or direction

### Quick Reference Commands

```bash
# Setup
bundle install
bundle exec rails db:create db:migrate

# Running
rails s                              # Start server on localhost:3000
bundle exec rails console            # Interactive Rails shell

# Testing
bundle exec rspec              # All tests
bundle exec rspec spec/controllers/file.rb  # Single test file

# Linting/Quality
bundle exec rubocop                  # Check for style issues
bundle exec rubocop -a               # Auto-fix style issues
bundle audit                         # Check for security vulnerabilities
ubs $(git diff --name-only)          # Scan changed files for bugs

# Database
bundle exec rails db:migrate         # Apply pending migrations
bundle exec rails db:rollback        # Undo last migration
bundle exec rails db:seed            # Load seed data

# Code Generation
rails generate model User             # Generate User model scaffold
rails generate migration AddEmailToUsers email:string  # Generate migration
rails generate controller Pages home about  # Generate controller

# Beads (Task Management)
bd ready --json                      # Get priority work
bd create "Task" --description="..." -t task -p 1 --json  # Create task
bd update <id> --status in_progress --json  # Claim work
bd close <id> --reason "Done" --json # Complete
bd sync                              # Push to git
```

---

## Best Practices Summary

✅ **DO**:
- Follow Rails conventions (CoC, MVC, REST)
- Write tests before code (TDD)
- Inject dependencies for testability
- Keep controllers skinny, models fat
- Use Active Record not raw SQL
- Validate input, encode output
- Comment "why", not "what"
- Cite code in plans: `app/models/user.rb:42`
- **Scan with UBS before commit** (catches bugs early)
- Use Beads for task tracking (not markdown TODOs)
- Request approval before merge
- Document architectural decisions
- Load `gems.md` when working with gems

❌ **DON'T**:
- Hardcode secrets, APIs, or config
- Skip tests or commit untested code
- Skip UBS scanning (bugs found early > bugs found in prod)
- Modify code without reading full context
- Use mock data in production
- Write SQL instead of Active Record
- Put business logic in controllers
- Introduce unjustified abstraction
- Commit to main/master directly
- Force-push to shared branches
- Ignore security checklist
- Create markdown TODOs instead of Beads tasks

---

**Each session starts fresh. Be precise, be decisive, be correct.**  
**Mission**: Build Rails applications respecting conventions, following established patterns, improving incrementally.  


<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

