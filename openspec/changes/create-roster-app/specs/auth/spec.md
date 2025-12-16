## ADDED Requirements

### Requirement: User Authentication
The system SHALL allow users to log in using an email and password.

#### Scenario: Successful Login
- **WHEN** a user enters a valid email and password
- **THEN** they are authenticated and redirected to their dashboard

### Requirement: PIN Authentication for Time Clock
The system SHALL require a 6-digit PIN for staff to clock in and out.

#### Scenario: Clock In with Valid PIN
- **WHEN** a staff member enters their correct 6-digit PIN
- **THEN** the system records their clock-in time

#### Scenario: Clock In with Invalid PIN
- **WHEN** a staff member enters an incorrect PIN
- **THEN** the system denies the action and shows an error message