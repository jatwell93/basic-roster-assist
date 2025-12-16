## Context
The project requires a robust rostering application with specific needs around budget forecasting, award interpretation, and strict time tracking. The user has specified Ruby on Rails and Tailwind CSS as the core stack, with a strong emphasis on TDD.

## Goals / Non-Goals
- **Goals:**
    - Build a secure, scalable web application.
    - Implement dual authentication (Email/Pass for access, PIN for time clock).
    - Integrate with Fair Work API for accurate wage data.
    - Provide real-time budget feedback during roster creation.
    - Ensure strict TDD practices are followed.
- **Non-Goals:**
    - Native mobile apps (web-based only for now).
    - Complex AI-driven auto-scheduling (manual with assistance).

## Decisions
- **Decision:** Use `devise` for authentication, extended with a custom PIN verification strategy for the time clock.
    - **Rationale:** Devise is the standard for Rails auth; extending it keeps user management centralized.
- **Decision:** Use `pundit` for authorization.
    - **Rationale:** Simple, policy-based authorization fits the role-based requirements (Admin, Manager, Staff).
- **Decision:** Service Object pattern for complex logic (e.g., `RosterCostCalculator`, `AwardRateFetcher`).
    - **Rationale:** Keeps models skinny and logic testable, crucial for the TDD requirement.
- **Decision:** Use `stimulus` for frontend interactivity (e.g., clock-in modal, roster drag-and-drop).
    - **Rationale:** Native to the Rails ecosystem, works well with Turbo.
- **Decision:** PostgreSQL as the database.
    - **Rationale:** Standard for Rails, robust support for complex queries needed for reporting.

## Risks / Trade-offs
- **Risk:** Fair Work API complexity or downtime.
    - **Mitigation:** Implement a caching layer and a fallback to manual rate entry.
- **Risk:** PIN security (e.g., sharing PINs).
    - **Mitigation:** Log IP addresses/locations for clock-ins; potential future geolocation requirement.

## Open Questions
- Specific Fair Work API endpoints and rate limits.