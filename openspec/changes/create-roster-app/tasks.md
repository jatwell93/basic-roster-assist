## 1. Project Setup
- [x] 1.1 Initialize Rails application with Tailwind CSS
- [x] 1.2 Configure RSpec, FactoryBot, and Shoulda Matchers
- [x] 1.3 Set up Devise for authentication
- [x] 1.4 Set up Pundit for authorization

## 2. Authentication & User Management
- [x] 2.1 Implement User model with roles (Admin, Manager, Staff)
- [x] 2.2 Add PIN column to User model (encrypted)
- [x] 2.3 Create PIN verification service for time clock

## 3. Roster Management
- [x] 3.1 Create BaseRoster and BaseShift models
- [ ] 3.2 Implement WeeklyRoster generation logic
- [ ] 3.3 Build Roster UI (Calendar view) with Stimulus

## 4. Budget & Forecasting
- [x] 4.1 Add SalesForecast model
- [x] 4.2 Implement RosterCostCalculator service
- [x] 4.3 Display Sales vs Wages % on Roster UI

## 5. Integrations
- [x] 5.1 Create FairWorkApiService
- [x] 5.2 Implement AwardRate model
- [ ] 5.3 Build Admin UI for mapping staff to awards

## 6. Time Tracking
- [x] 6.1 Create TimeEntry model (clock_in, clock_out)
- [x] 6.2 Implement ClockInService with shift validation
- [ ] 6.3 Build Staff Clock-In Interface (PIN entry) with historical list of clock in and out times shown

## 7. Reporting
- [x] 7.1 Implement WageReportGenerator (CSV export)
- [x] 7.2 Configure ActionMailer for notifications
- [x] 7.3 Create RosterPublishedNotification
- [ ] 7.4 Create action for exporting CSV budgets