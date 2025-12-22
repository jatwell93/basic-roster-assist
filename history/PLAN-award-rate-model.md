## Plan: Create AwardRate Model

**Analysis**:
- Current: `app/models/user.rb` (User model with role enum and hourly_rate), `app/services/fair_work_api_service.rb` (existing API service)
- Affected: New `app/models/award_rate.rb`, migration, `spec/models/award_rate_spec.rb`, `spec/factories/award_rates.rb`
- Pattern: Follows existing model patterns from `app/models/user.rb` (enums, associations, validations), service integration like existing services

**Reuse Strategy**:
- Extend User model with `has_many :award_rates` association
- Reuse FairWorkApiService for rate fetching (already exists and tested)
- Follow existing model validation patterns from User model
- Use FactoryBot factory pattern from existing factories
- Follow RSpec testing patterns from existing model specs

**Implementation Steps**:
1. Generate AwardRate model with migration (award_code, classification, rate, user_id, effective_date)
2. Add belongs_to/has_many associations between User and AwardRate
3. Add validations (presence of award_code, user_id; numericality of rate)
4. Add methods to fetch/update rates from FairWorkApiService
5. Add scopes for active awards, by award code, etc.
6. Create comprehensive RSpec tests (unit tests for model, associations, validations, API integration)
7. Create FactoryBot factory for AwardRate
8. Update User model to include award_rates association

**Integration Points**:
- AwardRate belongs_to User (staff member assignment)
- AwardRate integrates with FairWorkApiService for rate fetching
- AwardRate will be used by future roster cost calculation services
- No breaking changes to existing User model or services

**Tests**: Unit (model validations, associations, scopes, API integration) | Factory (AwardRate factory creation)

**Estimated Work**: 2-3 hours