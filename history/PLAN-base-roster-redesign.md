# Plan: Base Roster Redesign & Enhancement

**Objective**: Implement the wireframe from `base_roster_example.md` to provide a visual timeline roster, configurable opening hours, custom work sections, and detailed daily budgeting.

## 1. Data Model Changes

### A. Roster Configuration (`BaseRoster`)
We need to store the operational parameters and budget distributions.

**Migration**: `AddConfigToBaseRosters`
- `opening_time`: time (default '09:00')
- `closing_time`: time (default '17:00')
- `interval_minutes`: integer (default 30)
- `daily_budget_allocations`: jsonb (default `{}`) - To store manual daily targets like `{"monday": 500}`.
- `estimated_hourly_rate`: decimal (precision 8, scale 2) - Defaults to User's `hourly_rate` if nil.

### B. Custom Sections (`WorkSection`)
Replacing the rigid `shift_type` enum with user-definable sections (e.g., "Dispensary", "Shop Floor").

**Migration**: `CreateWorkSections`
- `name`: string
- `user_id`: bigint (FK)
- `created_at`, `updated_at`

**Migration**: `AddWorkSectionToBaseShifts`
- `work_section_id`: bigint (FK, nullable for now)
- *Note*: We will keep `shift_type` for backward compatibility but prioritize `work_section` in UI if present.

## 2. Business Logic updates

### `RosterBudgetCalculator` Service
Update to return structured data for the new UI:
- **Daily Breakdown**: Target Budget vs Actual Cost (Calculated from shifts * defined hourly rate).
- **Variance**: Daily and Weekly variance.
- **Section Breakdown**: Wages/Hours per section (Morning, Dispensary, etc.).

### `BaseRoster` Model
- Default `daily_budget_allocations` to split `weekly_sales_forecast` * `wage_percentage_goal` / 7 if empty.
- Validate `closing_time` > `opening_time`.

## 3. UI Implementation (`rosters/show.html.erb`)

### A. Budget Selection Panel (Top)
- **Inputs**: Sales Target, Wage % Goal, Average Hourly Rate.
- **Display**: Budget vs Actual, Variance.
- **Accordions**: Breakdown by Section (Wages & Hours).

### B. Roster Grid (Main)
- **Columns**: Days (Monday - Sunday).
- **Rows**: Time slots based on `opening_time`...`closing_time` in `interval_minutes` steps.
- **Cells**: Shifts rendered as blocks spanning their duration.
- **Interactions**: Click empty slot to add shift, click shift to edit.

### C. Daily Footer
- **Daily Budget**: Editable input (updates `daily_budget_allocations`).
- **Variance**: Calculated difference.

## 4. Implementation Steps

1.  **Database**: Create models and migrations for Sections and Roster Config.
2.  **Models**: Update associations and validations.
3.  **Controllers**: Update `RostersController` to permit new params.
4.  **Seeds**: Update seeds to include sample `WorkSections`.
5.  **Views**:
    - Create `_roster_grid.html.erb` partial.
    - Create `_budget_panel.html.erb` partial.
    - Update `show.html.erb` to assemble them.

## 5. Verification
- Test manual daily budget entry sums to weekly limit (or warns).
- Test visual rendering of 30min vs 60min intervals.
- Test "Dispensary" section appears in breakdowns.
