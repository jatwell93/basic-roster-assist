## ADDED Requirements

### Requirement: Base Roster Management
Admins SHALL be able to create and edit a perpetual "Base Roster" that serves as a template.

#### Scenario: Create Base Roster
- **WHEN** an admin defines shifts for a standard week or fortnight for rotating rosters (users may work 6 days one week then 4 the next)
- **THEN** the system saves this as the Base Roster

### Requirement: Weekly Roster Generation
The system SHALL allow generating specific weekly rosters from the Base Roster.

#### Scenario: Generate Weekly Roster
- **WHEN** an admin selects a week and clicks "Generate from Base"
- **THEN** a new editable roster for that week is created with shifts copied from the Base Roster

### Requirement: Roster Adjustment
Managers SHALL be able to add, remove, or modify shifts in a weekly roster.

#### Scenario: Add Casual Shift
- **WHEN** a manager adds a shift to a weekly roster
- **THEN** the shift is saved and the projected wage cost is updated

# NO VIEW FOR CREATING ROSTERS