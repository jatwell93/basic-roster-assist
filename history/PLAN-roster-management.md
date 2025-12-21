# Plan: Roster Management - BaseRoster and BaseShift Models

**Task ID**: basic-roster-assist-9qs
**Priority**: 2 (Medium)
**Issue Type**: task

## Analysis

### Current State
- Existing User model with Devise authentication and role-based access control (`app/models/user.rb:1-8`)
- Current database schema only includes users table (`db/schema.rb:17-28`)
- No existing roster or shift models
- Test pattern established using RSpec with shoulda-matchers (`spec/models/user_spec.rb:1-19`)

### Requirements Analysis
Based on `openspec/changes/create-roster-app/specs/roster/spec.md`:
- **Base Roster Management**: Admins need to create and edit perpetual "Base Roster" templates
- **Weekly Roster Generation**: System should allow generating specific weekly rosters from Base Roster
- **Roster Adjustment**: Managers need to add, remove, or modify shifts in weekly rosters

### Affected Components
- `app/models/base_roster.rb` (new model)
- `app/models/base_shift.rb` (new model)
- `db/migrate/[timestamp]_create_base_rosters.rb` (new migration)
- `db/migrate/[timestamp]_create_base_shifts.rb` (new migration)
- `spec/models/base_roster_spec.rb` (new test file)
- `spec/models/base_shift_spec.rb` (new test file)
- `app/models/user.rb` (potential association)

### Pattern Analysis
- Follows existing Rails conventions (ActiveRecord, migrations, RSpec testing)
- User model uses enum for roles - similar pattern could be used for shift types
- Test structure uses `describe` blocks with `it` statements and shoulda-matchers
- Models inherit from ApplicationRecord

## Reuse Strategy

### Existing Patterns to Extend
1. **Model Structure**: Follow `app/models/user.rb` pattern with ApplicationRecord inheritance
2. **Testing**: Use RSpec with shoulda-matchers as in `spec/models/user_spec.rb`
3. **Associations**: User has role enum - BaseShift could have shift_type enum
4. **Validation**: Use ActiveRecord validations similar to Devise validations in User model

### New Components Required
1. **BaseRoster Model**: Represents template rosters
2. **BaseShift Model**: Represents individual shifts within rosters
3. **Database Migrations**: For both new tables
4. **Associations**: BaseRoster has_many BaseShifts
5. **Enums**: Shift types (morning, afternoon, evening, night)

## Implementation Steps

### Phase 1: Model Creation (TDD Approach)
1. **Generate Migrations**
   - `rails generate migration CreateBaseRosters`
   - `rails generate migration CreateBaseShifts`

2. **Define Database Schema**
   - BaseRoster: name:string, description:text, week_type:integer (enum), starts_at:date, ends_at:date
   - BaseShift: base_roster:references, day_of_week:integer, shift_type:integer (enum), start_time:time, end_time:time, role_required:integer

3. **Create Models with Associations**
   - BaseRoster has_many :base_shifts, dependent: :destroy
   - BaseShift belongs_to :base_roster
   - Enums for shift_type and day_of_week

4. **Add Validations**
   - BaseRoster: presence validations, date range validation
   - BaseShift: presence validations, time range validation, no overlapping shifts

### Phase 2: Testing
1. **Unit Tests for BaseRoster**
   - Validations (name, dates, associations)
   - Enum functionality
   - Association tests

2. **Unit Tests for BaseShift**
   - Validations (times, day_of_week, shift_type)
   - Enum functionality
   - Association tests
   - Custom validation tests (no overlapping shifts)

3. **Integration Tests**
   - BaseRoster with multiple BaseShifts
   - Validation of shift overlaps

### Phase 3: Quality Assurance
1. Run full test suite: `bundle exec rails test`
2. Run linter: `bundle exec rubocop -a`
3. Run UBS scanner: `ubs <changed-files>`
4. Verify all checks pass

## Integration Points

### With Existing System
- **User Model**: Future association where User can have assigned shifts
- **Authentication**: BaseRoster management restricted to admin/manager roles
- **Authorization**: Policy-based access control for roster management

### API Design (Future)
- `GET /base_rosters` - List all base rosters
- `POST /base_rosters` - Create new base roster
- `GET /base_rosters/:id` - Show specific base roster with shifts
- `PATCH/PUT /base_rosters/:id` - Update base roster
- `DELETE /base_rosters/:id` - Delete base roster

## Database Schema Design

### base_rosters Table
```ruby
create_table :base_rosters do |t|
  t.string :name, null: false
  t.text :description
  t.integer :week_type, default: 0 # weekly, fortnightly
  t.date :starts_at, null: false
  t.date :ends_at, null: false
  t.timestamps
end
```

### base_shifts Table
```ruby
create_table :base_shifts do |t|
  t.references :base_roster, foreign_key: true
  t.integer :day_of_week, null: false # 0-6 (Sunday-Saturday)
  t.integer :shift_type, null: false # morning, afternoon, evening, night
  t.time :start_time, null: false
  t.time :end_time, null: false
  t.integer :role_required # staff, manager, admin
  t.timestamps
end
```

## Enums Design

### BaseRoster Enums
```ruby
enum week_type: { weekly: 0, fortnightly: 1 }
```

### BaseShift Enums
```ruby
enum day_of_week: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
enum shift_type: { morning: 0, afternoon: 1, evening: 2, night: 3 }
```

## Validation Rules

### BaseRoster Validations
- `validates :name, presence: true, length: { maximum: 100 }`
- `validates :starts_at, presence: true`
- `validates :ends_at, presence: true`
- `validate :end_after_start` (custom validation)

### BaseShift Validations
- `validates :day_of_week, presence: true`
- `validates :shift_type, presence: true`
- `validates :start_time, presence: true`
- `validates :end_time, presence: true`
- `validate :end_after_start` (custom validation)
- `validate :no_overlapping_shifts` (custom validation)

## Test Coverage Plan

### BaseRoster Spec (`spec/models/base_roster_spec.rb`)
```ruby
RSpec.describe BaseRoster, type: :model do
  describe 'enums' do
    it { should define_enum_for(:week_type).with_values(weekly: 0, fortnightly: 1) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
  end

  describe 'associations' do
    it { should have_many(:base_shifts).dependent(:destroy) }
  end

  describe 'custom validations' do
    it 'validates end date is after start date'
  end
end
```

### BaseShift Spec (`spec/models/base_shift_spec.rb`)
```ruby
RSpec.describe BaseShift, type: :model do
  describe 'enums' do
    it { should define_enum_for(:day_of_week).with_values(sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6) }
    it { should define_enum_for(:shift_type).with_values(morning: 0, afternoon: 1, evening: 2, night: 3) }
  end

  describe 'validations' do
    it { should validate_presence_of(:day_of_week) }
    it { should validate_presence_of(:shift_type) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
  end

  describe 'associations' do
    it { should belong_to(:base_roster) }
  end

  describe 'custom validations' do
    it 'validates end time is after start time'
    it 'validates no overlapping shifts for same day and role'
  end
end
```

## Estimated Work

- **Database Design**: 1 hour
- **Model Implementation**: 2 hours
- **Test Writing**: 2 hours
- **Validation Logic**: 1 hour
- **Quality Assurance**: 1 hour
- **Total**: 7 hours

## Success Criteria

✅ BaseRoster model created with proper associations and validations
✅ BaseShift model created with proper associations and validations
✅ Database migrations for both models
✅ Comprehensive test coverage (unit tests for both models)
✅ All tests passing
✅ Linter clean (rubocop)
✅ UBS scan passed (no critical/important issues)
✅ Follows Rails conventions and existing code patterns

## Next Steps

1. **PLAN State**: Submit this plan for approval
2. **BUILD State**: Implement models, migrations, and tests using TDD
3. **DIFF State**: Present changes for review
4. **QA State**: Run comprehensive test suite
5. **APPROVAL State**: Get user approval
6. **APPLY State**: Merge changes
7. **DOCS State**: Update documentation if needed