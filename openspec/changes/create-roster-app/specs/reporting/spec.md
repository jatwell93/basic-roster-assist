## ADDED Requirements

### Requirement: Wage Reporting
The system SHALL generate detailed wage reports for a specified period.

#### Scenario: Generate CSV Report
- **WHEN** an accountant requests a wage report for the last fortnight
- **THEN** the system generates a CSV file containing hours worked and wages due for each staff member

### Requirement: Email Notifications
The system SHALL send email notifications for key events.

#### Scenario: Send Roster Notification
- **WHEN** a manager publishes a new roster
- **THEN** all affected staff members receive an email notification