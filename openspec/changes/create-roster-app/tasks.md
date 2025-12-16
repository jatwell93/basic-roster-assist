## 1. Project Setup
- [ ] 1.1 Initialize Rails application with Tailwind CSS
- [ ] 1.2 Configure RSpec, FactoryBot, and Shoulda Matchers
- [ ] 1.3 Set up Devise for authentication
- [ ] 1.4 Set up Pundit for authorization

## 2. Authentication & User Management
- [ ] 2.1 Implement User model with roles (Admin, Manager, Staff)
- [ ] 2.2 Add PIN column to User model (encrypted)
- [ ] 2.3 Create PIN verification service for time clock

## 3. Roster Management
- [ ] 3.1 Create BaseRoster and BaseShift models
- [ ] 3.2 Implement WeeklyRoster generation logic
- [ ] 3.3 Build Roster UI (Calendar view) with Stimulus

## 4. Budget & Forecasting
- [ ] 4.1 Add SalesForecast model
- [ ] 4.2 Implement RosterCostCalculator service
- [ ] 4.3 Display Sales vs Wages % on Roster UI

## 5. Integrations
- [ ] 5.1 Create FairWorkApiService
- [ ] 5.2 Implement AwardRate model
- [ ] 5.3 Build Admin UI for mapping staff to awards

## 6. Time Tracking
- [ ] 6.1 Create TimeEntry model (clock_in, clock_out)
- [ ] 6.2 Implement ClockInService with shift validation
- [ ] 6.3 Build Staff Clock-In Interface (PIN entry)

## 7. Reporting
- [ ] 7.1 Implement WageReportGenerator (CSV export)
- [ ] 7.2 Configure ActionMailer for notifications
- [ ] 7.3 Create RosterPublishedNotification