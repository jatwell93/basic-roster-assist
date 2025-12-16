## ADDED Requirements

### Requirement: Sales Forecasting
Users SHALL be able to input forecasted sales figures for a roster period.

#### Scenario: Input Sales Forecast
- **WHEN** a manager enters expected sales for each day of the week
- **THEN** the system stores these figures for calculation

### Requirement: Wage Cost Calculation
The system SHALL calculate the projected wage cost based on rostered shifts and staff rates.

#### Scenario: Calculate Wage Cost
- **WHEN** shifts are added to a roster
- **THEN** the total wage cost is updated in real-time

### Requirement: Sales vs Wages Percentage
The system SHALL display the Sales vs Wages percentage.

#### Scenario: Display Percentage
- **WHEN** both sales forecast and rostered shifts exist
- **THEN** the system displays the calculated wage percentage (Total Wages / Total Sales * 100)