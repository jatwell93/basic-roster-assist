## Plan: RosterPublishedNotification Service

**Task**: Create RosterPublishedNotification service to send email notifications when rosters are published. This service will integrate with ActionMailer and use existing email templates. Follow existing notification patterns in the codebase.

### Analysis
- **Current**: `app/mailers/application_mailer.rb` (basic mailer setup), `app/models/base_roster.rb` (roster model with user association)
- **Affected**: New `app/services/roster_published_notification.rb`, new `app/mailers/roster_mailer.rb`, `spec/services/roster_published_notification_spec.rb`
- **Pattern**: Follows existing service pattern from `app/services/clock_in_service.rb` (initialize with params, main action methods, private helpers)

### Reuse Strategy
- Extend existing ApplicationMailer pattern for roster-specific emails
- Follow ClockInService pattern for service structure (initialize, call method, error handling)
- Reuse BaseRoster associations to get affected users
- No new models needed - leverage existing BaseRoster and User models

### Implementation Steps
1. Create RosterMailer inheriting from ApplicationMailer (line 1-10)
2. Add roster_published email template method (line 12-25)
3. Create RosterPublishedNotification service class (line 1-30)
4. Add initialize method with roster parameter (line 5-10)
5. Add call method to orchestrate notification sending (line 12-20)
6. Add private methods for user collection and email sending (line 22-35)
7. Write comprehensive tests covering success/failure scenarios (50+ lines)
8. Add proper error handling and logging

### Business Rules
- Send notifications to all users associated with the roster
- Handle email delivery failures gracefully (don't crash service)
- Log notification attempts for debugging
- Support batch email sending for performance

### Integration Points
- Called from roster publishing workflow (future controller/service)
- Uses existing BaseRoster.user association to find recipients
- Integrates with Rails ActionMailer for email delivery
- No breaking changes to existing models

### Tests
- Unit tests for service initialization and validation
- Integration tests for email sending (mocked)
- Error handling tests for delivery failures
- Edge case tests (empty roster, invalid emails)

**Estimated Work**: 2-3 hours