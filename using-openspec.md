# Green-Field Project Workflow with OpenSpec

For a green-field project, you'd start with an initial proposal to establish the app's foundation, then create separate proposals for each new feature. The file is called `proposal.md` (not `plan.md`), and you'll use the CLI extensively for quality control.

## Initial Project Setup

1. **Create the foundational proposal**:
   ```bash
   /openspec:proposal "Help me write a proposal for this app with tech stack, frameworks, architectural patterns, and coding standards"
   ```
   This scaffolds `openspec/changes/[change-id]/` with `proposal.md`, `tasks.md`, and optional `design.md` [1](#1-0) .

2. **Add design decisions** (if needed):
   Create `design.md` when your solution spans multiple systems, introduces new patterns, or requires trade-off discussion [2](#1-1) .

3. **Generate implementation tasks**:
   The AI creates `tasks.md` as an ordered checklist of verifiable work items [3](#1-2) .

## Feature Development Cycle

Each new feature gets its own proposal:
- **Yes**, create a new `proposal.md` for each feature/capability [4](#1-3) 
- Use verb-led change IDs: `add-user-auth`, `update-payment-flow`, `remove-legacy-endpoint` [5](#1-4) 

## CLI Quality Maintenance

### Core Validation Commands

```bash
# List all active changes
openspec list

# Strict validation (prevents implementation until fixed)
openspec validate <change-id> --strict

# Review proposal details
openspec show <change-id>

# Bulk validation
openspec validate --all --strict
```

The `validate` command checks:
- Schema compliance via Zod
- Business rules (delta limits, header formats)
- Content rules (SHALL/MUST keywords, scenario structure) [6](#1-5) 

### Quality Gates

1. **Before implementation**: Run `openspec validate <id> --strict` - all issues must be resolved [7](#1-6) 
2. **During implementation**: Use `openspec show <id> --json --deltas-only` to reference specs while coding [8](#1-7) 
3. **Before archive**: Run `openspec validate --strict` to ensure everything passes [9](#1-8) 

## Archiving Process

When implementation is complete:
```bash
openspec archive <change-id> --yes
```

This:
1. Applies delta changes to `specs/` in order: RENAMED → REMOVED → MODIFIED → ADDED [10](#1-9) 
2. Moves the change to `changes/archive/YYYY-MM-DD-[name]/` [11](#1-10) 
3. Validates the archived change [9](#1-8) 

## Notes

- For green-field projects, your first proposal establishes the project context in `openspec/project.md` [12](#1-11) 
- Skip proposals for bug fixes, typos, and non-breaking dependency updates [13](#1-12) 
- Use `--yes` flag with archive for non-interactive automation [14](#1-13) 

Wiki pages you might want to explore:
- [Overview (Fission-AI/OpenSpec)](/wiki/Fission-AI/OpenSpec#1)
- [Slash Commands and Workflows (Fission-AI/OpenSpec)](/wiki/Fission-AI/OpenSpec#5.2)
---
# Green-Field Project Approach

For a green-field roster app, you should establish the overall project context first, then work on features incrementally with separate proposals. This gives you both direction and flexibility.

## Recommended Approach

### 1. Start with Project Context
First populate `openspec/project.md` with your overall vision:
- App purpose and stakeholders
- Complete tech stack (React, Node.js, PostgreSQL, etc.)
- Architectural patterns (MVC, microservices, etc.)
- Coding standards and conventions [1](#2-0) 

This context guides all subsequent features and ensures consistency.

### 2. Create Feature-Specific Proposals
Then work on features one at a time with separate proposals:
```bash
/openspec:proposal "Add schedule management to the roster app"
```
This creates `openspec/changes/add-schedule/` with:
- `proposal.md` - Why and what for the schedule feature
- `tasks.md` - Implementation checklist for schedule
- `specs/schedule/spec.md` - Requirements for schedule capability [2](#2-1) 

### 3. Archive and Iterate
Complete the feature, archive it, then move to the next:
```bash
openspec archive add-schedule --yes
```
This updates `specs/schedule/spec.md` with the implemented requirements [3](#2-2) .

Then create the next proposal:
```bash
/openspec:proposal "Add employee management to the roster app"
```

## Why This Hybrid Approach Works

- **Direction**: The project context in `openspec/project.md` ensures all features align with your vision
- **Flexibility**: Separate proposals let you adjust scope based on learning and feedback
- **Traceability**: Each feature has its own proposal, tasks, and spec delta for clear audit trails
- **Incremental Value**: You ship working features while building toward the full vision [4](#2-3) 

## Example Workflow for Roster App

1. **Initial Setup**:
   - `openspec init`
   - Populate `openspec/project.md` with full app context

2. **Feature 1 - Schedule**:
   - Create proposal for schedule management
   - Implement tasks
   - Archive → updates `specs/schedule/spec.md`

3. **Feature 2 - Employees**:
   - Create proposal for employee management
   - Implement tasks
   - Archive → updates `specs/employees/spec.md`

4. **Feature 3 - Notifications**:
   - Create proposal for shift notifications
   - Implement tasks
   - Archive → updates `specs/notifications/spec.md`

Each feature builds on the established project context while maintaining clear boundaries and change tracking.

## Notes

- The project context can be updated as your understanding evolves
- Each proposal references `openspec/project.md` to maintain consistency [5](#2-4) 
- Use `openspec list --specs` to see all capabilities as they grow
- Run `openspec validate --strict` before archiving each feature [6](#2-5) 

Wiki pages you might want to explore:
- [Directory Structure (Fission-AI/OpenSpec)](/wiki/Fission-AI/OpenSpec#3.1)
- [Slash Commands and Workflows (Fission-AI/OpenSpec)](/wiki/Fission-AI/OpenSpec#5.2)
- [Template System (Fission-AI/OpenSpec)](/wiki/Fission-AI/OpenSpec#6.7)

