## ADDED Requirements

### Requirement: Fair Work API Integration
The system SHALL integrate with the Fair Work API to retrieve current award rates.

#### Scenario: Fetch Award Rates
- **WHEN** an admin configures an award for a staff member
- **THEN** the system fetches and stores the current base rate from the Fair Work API

#### Scenario: API Failure Fallback
- **WHEN** the Fair Work API is unavailable
- **THEN** the system allows manual entry of wage rates