## ADDED Requirements

### Requirement: Shift Assignment Validation
The system SHALL only allow staff to clock in if they have an assigned shift within a configurable time window.

#### Scenario: Clock In Within Window
- **WHEN** a staff member attempts to clock in 10 minutes before their shift start
- **THEN** the system allows the clock-in

#### Scenario: Clock In Outside Window
- **WHEN** a staff member attempts to clock in 2 hours before their shift start
- **THEN** the system denies the clock-in and displays an error

### Requirement: Clock Out
The system SHALL allow staff to clock out at the end of their shift.

#### Scenario: Successful Clock Out
- **WHEN** a staff member enters their PIN to clock out
- **THEN** the system records the end time

# NO VIEW TO SEE CLOCK IN AND OUT INFO