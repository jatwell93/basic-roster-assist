# Change: Create Rostering Web Application

## Why
The goal is to provide a centralized platform for efficient, transparent, and budget-conscious workforce management. This application will help managers create rosters aligned with sales targets, ensure wage transparency for staff, and automate wage reporting for accountants.

## What Changes
- **New Application:** A Ruby on Rails web application with Tailwind CSS.
- **Authentication:** Email/Password for account access, plus 6-digit PIN for staff clock-in/out.
- **Roster Management:** Creation of base and weekly/fortnightly rosters with budget forecasting.
- **Time Tracking:** Clock-in/out functionality restricted to assigned shifts.
- **Integrations:** Integration with Fair Work API for award-based wage rates.
- **Reporting:** CSV exports and email notifications for wage and timekeeping reports.

## Impact
- **New Specs:** `auth`, `roster`, `budget`, `time-tracking`, `reporting`, `integrations`.
- **New Codebase:** Full Rails application structure.