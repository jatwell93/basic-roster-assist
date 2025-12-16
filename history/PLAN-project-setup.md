## Plan: Project Setup Completion

**Analysis**:
- Current: Rails app initialized with Tailwind CSS.
- Missing:
    - RSpec configuration for FactoryBot and Shoulda Matchers.
    - Devise installation (initializer missing).
    - Pundit installation (policies directory missing).
- Affected: `spec/rails_helper.rb`, `config/initializers/devise.rb`, `app/policies/`.

**Reuse Strategy**:
- Use standard Rails generators for Devise and Pundit.
- Use standard configuration for RSpec/FactoryBot/Shoulda Matchers.

**Implementation Steps**:
1.  **Configure RSpec**:
    - Edit `spec/rails_helper.rb` to include `FactoryBot::Syntax::Methods`.
    - Edit `spec/rails_helper.rb` to configure `Shoulda::Matchers`.
2.  **Install Devise**:
    - Run `bundle exec rails generate devise:install`.
    - Configure default URL options in `config/environments/development.rb` and `test.rb` (Devise requirement).
3.  **Install Pundit**:
    - Run `bundle exec rails generate pundit:install`.
4.  **Verify**:
    - Run `bundle exec rails test` (or `rspec`) to ensure no configuration errors.

**Integration Points**:
- `spec/rails_helper.rb`
- `config/initializers/devise.rb`
- `app/policies/application_policy.rb`

**Tests**:
- Run `bundle exec rspec` to verify configuration.

**Estimated Work**: 30 minutes
