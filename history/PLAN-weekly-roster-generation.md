## Plan: Implement WeeklyRoster generation logic

**Analysis**:
- Current: `app/models/base_roster.rb` and `app/models/base_shift.rb` define roster templates with recurring patterns
- Current: `app/services/roster_cost_calculator.rb` calculates costs for base rosters
- Missing: No WeeklyRoster model or generation logic to create actual weekly schedules from templates
- Affected: `app/models/base_roster.rb`, `app/services/roster_cost_calculator.rb`, `spec/models/base_roster_spec.rb`, `spec/services/roster_cost_calculator_spec.rb`
- Pattern: Follow existing service pattern from `app/services/roster_cost_calculator.rb`

**Reuse Strategy**:
- Extend BaseRoster model with weekly roster generation methods
- Create WeeklyRosterGenerationService following RosterCostCalculator pattern
- Add WeeklyRoster and WeeklyShift models following BaseRoster/BaseShift structure
- Follow existing test patterns from `spec/services/roster_cost_calculator_spec.rb`

**Implementation Steps**:
1. Create WeeklyRoster and WeeklyShift models with proper associations
2. Create WeeklyRosterGenerationService to generate weekly schedules from base rosters
3. Add generation methods to BaseRoster model following existing patterns
4. Write comprehensive tests following `spec/services/roster_cost_calculator_spec.rb` pattern
5. Add validation and error handling following existing model patterns

**Integration Points**:
- BaseRoster model gets new `generate_weekly_rosters` method
- WeeklyRosterGenerationService integrates with existing roster cost calculation
- No breaking changes to existing API
- Follows existing Rails conventions and model patterns

**Tests**: Unit (WeeklyRoster model, WeeklyRosterGenerationService) | Integration (BaseRoster generation methods) | Manual (verification of generated schedules)

**Estimated Work**: 2-3 hours