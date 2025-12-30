## Plan: Build Admin UI for mapping staff to awards

**Task**: Create an admin interface for mapping staff members to Fair Work awards. This should allow admins to assign awards to users and manage award rates.

**Analysis**:
- Current: `app/controllers/awards_controller.rb` (CRUD for award rates only)
- Affected: `app/controllers/awards_controller.rb`, `app/views/awards/`, `app/models/user.rb`
- Pattern: Extends existing admin awards controller with user assignment functionality

**Reuse Strategy**:
- Extend existing `AwardsController` with new actions for user-award mapping
- Follow existing admin UI patterns from `app/views/awards/index.html.erb`
- Use existing `AwardRate` model and associations
- Follow existing Tailwind CSS styling patterns

**Implementation Steps**:
1. Add new route for user-award mapping: `get 'awards/users', to: 'awards#users'`
2. Add `users` action to `AwardsController` to list users with their current awards
3. Create `app/views/awards/users.html.erb` view showing users and award assignment interface
4. Add methods to `User` model for award management (if needed)
5. Add JavaScript for dynamic award assignment (optional enhancement)
6. Write controller and integration tests

**Integration Points**:
- Uses existing `AwardRate` model and `User.has_many :award_rates` association
- Admin-only access via existing constraints
- No breaking changes to existing award rate management

**Tests**: Unit (model methods) | Integration (controller actions, views) | Manual (award assignment workflow)

**Estimated Work**: 2-3 hours