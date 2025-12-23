## Plan: Create UI Components for Roster Management

**Task ID**: basic-roster-assist-efa
**Priority**: 3 (Low)
**Type**: Feature

### Analysis
- **Current State**: Minimal UI exists (only mailer views and basic layouts). Project has comprehensive data models (User, BaseRoster, BaseShift, TimeEntry, AwardRate) and services (ClockInService, RosterCostCalculator)
- **Affected Components**:
  - New controllers: RostersController, ClockInsController, AwardsController
  - New views: Calendar interface, PIN verification form, award mapping admin UI
  - Routes: RESTful routes for roster management, clock-in, and awards
  - Models: May need minor extensions for UI requirements
- **Existing Patterns**: Uses Devise authentication, Tailwind CSS styling, existing service layer architecture

### Reuse Strategy
- **Controller Pattern**: Follow Rails REST conventions with skinny controllers delegating to services
- **View Pattern**: Use existing Tailwind CSS setup from application layout
- **Authentication**: Leverage existing Devise setup with role-based access (User.role field exists)
- **Service Integration**: Reuse ClockInService for PIN verification logic
- **Model Extensions**: Add minimal UI-specific methods to existing models rather than creating new ones

### Implementation Steps

#### 1. Create RostersController and Calendar View (2-3 hours)
- Generate `app/controllers/rosters_controller.rb` with index/show actions
- Create calendar view showing BaseRoster data with weekly/fortnightly/monthly display
- Add routes: `resources :rosters, only: [:index, :show]`
- Style with Tailwind CSS for responsive calendar layout

#### 2. Create ClockInsController and PIN Verification Interface (2-3 hours)
- Generate `app/controllers/clock_ins_controller.rb` with new/create actions
- Create PIN entry form with JavaScript validation
- Integrate with existing ClockInService for authentication
- Add routes: `resources :clock_ins, only: [:new, :create]`
- Handle TimeEntry creation on successful clock-in

#### 3. Create AwardsController and Admin Mapping UI (2-3 hours)
- Generate `app/controllers/awards_controller.rb` with CRUD actions
- Create admin interface for managing AwardRate mappings
- Add role-based authorization (admin users only)
- Add routes: `resources :awards` with admin constraints
- Include award rate assignment to users

#### 4. Update Routes and Navigation (1 hour)
- Add all new routes to `config/routes.rb`
- Update application layout with navigation links
- Add role-based menu visibility

#### 5. Add Basic Styling and Responsive Design (1-2 hours)
- Ensure all views are mobile-responsive
- Apply consistent Tailwind CSS styling
- Add loading states and error handling

### Integration Points
- **Authentication**: All controllers use `before_action :authenticate_user!`
- **Authorization**: Awards controller restricts to admin role users
- **Services**: ClockInsController delegates PIN verification to ClockInService
- **Models**: Reuse existing associations (User has_many :base_rosters, etc.)
- **No Breaking Changes**: All new functionality is additive

### Tests
- **Controller Tests**: Unit tests for all controller actions (6-8 specs)
- **Integration Tests**: Feature tests for clock-in flow and calendar display
- **View Tests**: Basic view rendering tests
- **Authorization Tests**: Ensure admin-only routes are protected

### Success Criteria
- ✅ Calendar view displays roster data in weekly/monthly format
- ✅ Staff can clock in/out using PIN verification
- ✅ Admins can manage award rate mappings
- ✅ All views are responsive and styled with Tailwind CSS
- ✅ Role-based access control is implemented
- ✅ No existing functionality is broken

### Estimated Work
**Total**: 8-11 hours
- Planning: 30 minutes
- Implementation: 6-8 hours
- Testing: 1-2 hours
- Styling/Polish: 1 hour

### Risks & Mitigations
- **Complex Calendar Logic**: Start with simple weekly view, can enhance later
- **PIN Security**: Use existing encrypted PIN fields, no custom crypto
- **Role Authorization**: Leverage existing User.role field, add helper methods
- **Mobile Responsiveness**: Use Tailwind responsive utilities from start

### Dependencies
- Requires existing models: User, BaseRoster, BaseShift, TimeEntry, AwardRate
- Requires existing services: ClockInService
- Requires Devise authentication setup
- Requires Tailwind CSS configuration