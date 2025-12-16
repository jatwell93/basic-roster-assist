# Roster Application - Development Setup Guide

## Prerequisites Installation

### 1. Ruby Installation (RubyInstaller for Windows)

1. Download **Ruby+Devkit 3.2.x** or higher from https://rubyinstaller.org/
2. Run the installer and select "Add Ruby executables to your PATH"
3. After installation completes, the installer will prompt you to run `ridk install`
4. In the command prompt that appears, press **ENTER** to install MSYS2 (option 1)
5. Wait for installation to complete

**Verify Ruby Installation:**
```bash
ruby --version
# Expected: ruby 3.2.x or higher
```

### 2. Rails Installation

```bash
gem install rails
# This will install the latest Rails 7.x

# Verify installation
rails --version
# Expected: Rails 7.x.x
```

### 3. PostgreSQL Installation

1. Download PostgreSQL from https://www.postgresql.org/download/windows/
2. Run the installer (recommended version: 15.x or higher)
3. During installation:
   - Remember the password you set for the `postgres` user
   - Default port: 5432 (keep this unless you have a conflict)
   - Install Stack Builder components if prompted

**Verify PostgreSQL:**
```bash
psql --version
# Expected: psql (PostgreSQL) 15.x or higher
```

### 4. Node.js Installation (for Asset Compilation)

1. Download Node.js LTS from https://nodejs.org/
2. Run the installer with default options

**Verify Node.js:**
```bash
node --version
# Expected: v18.x or higher

npm --version
# Expected: 9.x or higher
```

---

## Project Initialization

Once all prerequisites are installed, run these commands:

### 1. Create Rails Application

```bash
# Navigate to project directory
cd c:/Users/josha/basic-roster-assist

# Create new Rails app with PostgreSQL and Tailwind CSS
rails new . --database=postgresql --css=tailwind --skip-git

# Note: Use --skip-git since we already have a git repo
```

### 2. Configure Database

Edit `config/database.yml` and update the development section:

```yaml
development:
  <<: *default
  database: roster_app_development
  username: postgres
  password: YOUR_POSTGRES_PASSWORD_HERE
  host: localhost
```

### 3. Create Database

```bash
bundle exec rails db:create
```

### 4. Install Testing Gems

Add to `Gemfile`:

```ruby
group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end
```

Then run:

```bash
bundle install
rails generate rspec:install
```

### 5. Install Authentication & Authorization Gems

Add to `Gemfile`:

```ruby
gem 'devise'
gem 'pundit', '~> 2.3'
```

Then run:

```bash
bundle install
rails generate devise:install
rails generate pundit:install
```

### 6. Configure RuboCop (Linter)

Create `.rubocop.yml`:

```yaml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.2
  Exclude:
    - 'db/schema.rb'
    - 'db/migrate/*'
    - 'bin/*'
    - 'node_modules/**/*'
    - 'vendor/**/*'

Style/Documentation:
  Enabled: false

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'config/routes.rb'
```

### 7. Verify Setup

```bash
# Run Rails server
rails server

# In another terminal, run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

---

## Quick Reference Commands

### Development
```bash
rails server                    # Start server (http://localhost:3000)
rails console                   # Interactive Rails console
rails routes                    # Show all routes
```

### Database
```bash
rails db:create                 # Create database
rails db:migrate                # Run migrations
rails db:rollback               # Undo last migration
rails db:seed                   # Load seed data
rails db:reset                  # Drop, create, migrate, seed
```

### Testing
```bash
bundle exec rspec               # Run all tests
bundle exec rspec spec/models   # Run model tests only
bundle exec rspec spec/models/user_spec.rb  # Run specific file
```

### Code Quality
```bash
bundle exec rubocop             # Check code style
bundle exec rubocop -a          # Auto-fix issues
bundle audit                    # Check for security vulnerabilities
```

### Generators
```bash
rails generate model User email:string
rails generate controller Users index show
rails generate migration AddRoleToUsers role:integer
```

---

## Troubleshooting

### PostgreSQL Connection Issues

If you get "could not connect to server":

1. Check PostgreSQL service is running:
   - Open Services (Win+R, type `services.msc`)
   - Find "postgresql-x64-15" (or similar)
   - Ensure it's "Running"

2. Verify credentials in `config/database.yml`

### Bundle Install Fails

If `bundle install` fails with native extension errors:

```bash
# Install missing dependencies via ridk
ridk enable
gem install pg -- --with-pg-config="C:/Program Files/PostgreSQL/15/bin/pg_config.exe"
```

### Rails Server Won't Start

1. Check if port 3000 is already in use
2. Try: `rails server -p 3001` (use different port)
3. Check for syntax errors: `ruby -c config/routes.rb`

---

## Next Steps After Setup

Once setup is complete, we'll proceed with:

1. ✅ Task 1.1: Rails app initialized with Tailwind CSS
2. Task 1.2: Configure RSpec, FactoryBot, Shoulda Matchers
3. Task 1.3: Set up Devise for authentication
4. Task 1.4: Set up Pundit for authorization
5. Task 2.1: Implement User model with roles

---

## Environment Variables

Create `.env.example` (never commit actual `.env`):

```bash
# Database
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password_here

# Fair Work API (to be configured later)
FAIR_WORK_API_KEY=your_api_key_here

# Email (for production)
SMTP_ADDRESS=smtp.example.com
SMTP_USERNAME=your_email@example.com
SMTP_PASSWORD=your_smtp_password
```

---

**Ready to proceed?** Once Ruby, Rails, PostgreSQL, and Node.js are installed, let me know and we'll initialize the Rails application!