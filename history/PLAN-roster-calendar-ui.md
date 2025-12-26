## Plan: Build Roster UI (Calendar view) with Stimulus

**Task**: Create a calendar-based UI for viewing and managing rosters using Stimulus.js. This should display weekly schedules, allow staff assignment, and integrate with existing roster models.

### Analysis
- **Current**: Basic roster index view (`app/views/rosters/index.html.erb`) showing roster cards with Tailwind CSS styling
- **Affected**:
  - `app/controllers/rosters_controller.rb` - need calendar action
  - `config/routes.rb` - need calendar route
  - `app/views/rosters/` - need calendar view
  - `app/javascript/controllers/` - need calendar Stimulus controller
  - `spec/controllers/rosters_controller_spec.rb` - need calendar action tests
- **Pattern**: Follow existing Tailwind CSS styling patterns from roster index, use Stimulus for interactivity

### Reuse Strategy
- **Extend existing rosters controller** with calendar action (follows Rails REST conventions)
- **Create new Stimulus controller** for calendar interactions (follows existing Stimulus patterns)
- **Use existing WeeklyRoster/WeeklyShift models** with WeeklyRosterGenerationService
- **Follow existing Tailwind CSS styling** from roster index view
- **Reuse authentication patterns** from existing controllers

### Implementation Steps
1. **Add calendar route and controller action**
   - Add `get "calendar", to: "rosters#calendar"` route
   - Create `calendar` action in `RostersController`
   - Load weekly rosters for current week/date range

2. **Create calendar view with Tailwind CSS**
   - Create `app/views/rosters/calendar.html.erb`
   - Implement weekly calendar grid layout
   - Display shifts by day/time with staff assignments
   - Use responsive design following existing patterns

3. **Create Stimulus controller for calendar interactions**
   - Create `app/javascript/controllers/calendar_controller.js`
   - Handle shift selection, drag-and-drop staff assignment
   - Implement AJAX calls for updating assignments
   - Add keyboard navigation and accessibility

4. **Add staff assignment functionality**
   - Create form for assigning staff to shifts
   - Add validation and error handling
   - Update WeeklyShift records via AJAX

5. **Write integration tests**
   - Test calendar action loads correct data
   - Test Stimulus controller interactions
   - Test staff assignment workflow

### Integration Points
- **WeeklyRosterGenerationService**: Uses existing service to generate roster data
- **WeeklyRoster/WeeklyShift models**: Displays and updates existing model data
- **Authentication**: Requires user authentication (follows existing patterns)
- **Navigation**: Links from roster index to calendar view

### Tests
- **Controller tests**: Unit tests for calendar action data loading
- **Integration tests**: Feature tests for calendar display and interactions
- **Stimulus tests**: JavaScript tests for calendar controller functionality
- **Manual testing**: Verify calendar layout and staff assignment workflow

### Estimated Work
- **Backend**: 1-2 hours (controller action, routes)
- **Frontend**: 2-3 hours (calendar view, Stimulus controller)
- **Testing**: 1-2 hours (integration and JavaScript tests)
- **Total**: 4-7 hours

### Success Criteria
- Calendar displays weekly roster with proper time slots
- Staff can be assigned to shifts via drag-and-drop or selection
- Responsive design works on mobile and desktop
- All tests pass, follows Rails conventions
- Integrates seamlessly with existing roster management