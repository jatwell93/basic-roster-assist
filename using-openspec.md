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

/openspec-proposal.md Help me write a proposal for this app with tech stack, frameworks, architectural patterns, and coding standards. 
Purpose: To assist managers with rostering team members and planning rosters inline with budgets. Team members will benefit from having their hours tracked and being able to see when they have clocked in and out to increase transperancy around wages. 
Stakeholders: Store owners, Managers, staff and accountants. 
Overview:The app will be a rostering web application where the admin can create rosters, both a base roster and weekly/fortnightly rosters that can be based off the base roster and then edited for business needs such as increasing casual labour on a busy week for ad-hoc planning. Users will be able to forecast yearly sales and then create weekly/fortnightly base rosters so they can match a target Sales vs Wages %. The rates will be autofilled using the base rates from several wage awards (e.g. the Pharmacy Award) OR manually edited by the admin. There will also be Users who can clock in and clock out from their assigned shifts (an exception should be raised if the user clocks in to a UNassigned shift). This tracking will allow the admin to create wage reports to assist with pays and time keeping and retention needs. Set up should be easy for both the admin and the users with simple profiles and 6-digit pin codes. 
Tech: The tech stack should use ruby on rails. Tailwind for styling CSS
Achitectural patterns: Mandatory TDD: The core principle established in development guidelines is that every line of production code must be written in response to a failing test: Three-Phase Cycle: The mandatory TDD workflow follows a strict three-phase sequence to prevent implementing code before tests are ready.  1. Stub Phase: Create a minimal skeleton that compiles but throws a "NotYetImplemented" error. 2. TDD Phase: Write comprehensive BEHAVIORAL tests that define the actual expected functionality and must fail naturally (the "Red" phase). 2. Tests are forbidden from checking for stub behavior or using certain anti-patterns ("Mock Theater"). 3. Implementation Phase: Write code (following explicit line-by-line pseudocode instructions) strictly to make the failing tests pass (the "Green" phase). Coding standards and conventions must be in-line iwth the rails style guide

help me draft a comprehensive technical proposal for a rostering web application designed to assist managers with team scheduling and budget-aligned workforce planning. The proposal must detail the technology stack, frameworks, architectural patterns, and coding standards.

**Application Purpose & Value Proposition:**
The primary purpose is to provide a centralized platform for efficient, transparent, and budget-conscious workforce management. For managers and store owners, it enables the creation, adjustment, and forecasting of rosters against sales targets (Sales vs. Wages %). For staff, it increases wage transparency through clear shift assignment and accurate time tracking via clock-in/clock-out functionality. For accountants, it automates wage reporting for payroll and compliance.

**Key Stakeholders:** Store Owners, Managers, Staff (Team Members), and Accountants.

**Core Feature Overview:**
1.  **Roster Management:** Admins can create a perpetual "Base Roster" and generate editable weekly/fortnightly rosters derived from it, allowing for ad-hoc adjustments (e.g., adding casual labor for busy periods).
2.  **Budget Forecasting & Planning:** Users can forecast annual sales and design base rosters to achieve a target Sales vs. Wages percentage, integrating financial planning directly into scheduling.
3.  **Award-Based & Manual Wage Rates:** Shift rates are auto-populated using base rates from relevant industry awards (e.g., Pharmacy Award) with admin override capability for manual edits.
4.  **Time & Attendance Tracking:** Staff can clock in and out only for their assigned shifts; the system must raise an exception for attempts to clock into unassigned shifts.
5.  **Reporting:** Generate detailed wage and timekeeping reports to streamline payroll processing and support staff retention analysis.
6.  **User Onboarding & Access:** Simplified setup with basic user profiles and secure 6-digit PIN code authentication for ease of use.

**Technical Specifications:**

*   **Primary Tech Stack:** Ruby on Rails.
*   **Frontend Styling:** Tailwind CSS.

**Mandatory Architectural & Development Pattern: Test-Driven Development (TDD)**
The entire codebase must be developed under a strict, three-phase TDD cycle. The core principle is that no production code is written without a failing test first.

1.  **Stub Phase:** Begin by creating a minimal, compilable code skeleton (e.g., empty class/method) that explicitly raises a "NotYetImplemented" error.
2.  **TDD Phase (Red):** Write comprehensive, behavioral tests that define the actual required functionality. These tests must fail naturally against the stub. Prohibit test anti-patterns such as "Mock Theater" (over-mocking implementation details) or writing tests that merely check for the presence of the stub's "NotYetImplemented" error.
3.  **Implementation Phase (Green):** Write production code strictly to make the failing tests pass. Implementation should follow explicit, line-by-line pseudocode instructions derived from the test specifications.

**Coding Standards:** All code must rigorously adhere to the conventions and style prescribed by the official Ruby on Rails style guide.