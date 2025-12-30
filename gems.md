# gems.md – Rails Gems Reference Guide

**Version**: 1.0 | **Purpose**: Quick reference for commonly-used Rails gems  
**Load When**: Agent asks about gem integration, patterns for specific libraries, or gem-specific best practices

---

## Table of Contents

1. [Authentication & Authorization](#1-authentication--authorization)
2. [Database & Query Optimization](#2-database--query-optimization)
3. [Testing](#3-testing)
4. [API Development](#4-api-development)
5. [Background Jobs](#5-background-jobs)
6. [Monitoring & Debugging](#6-monitoring--debugging)
7. [File Handling](#7-file-handling)
8. [Pagination & Search](#8-pagination--search)
9. [Performance & Caching](#9-performance--caching)
10. [Serialization](#10-serialization)
11. [Administration](#11-administration)

---

## 1. Authentication & Authorization

### Devise (Authentication)

**Purpose**: User authentication (login, signup, password reset)

**Standard Setup**:
```ruby
# Gemfile
gem 'devise'

# Generate
rails generate devise:install
rails generate devise User
rails db:migrate
```

**Usage**:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
end

# app/controllers/protected_controller.rb
class ProtectedController < ApplicationController
  before_action :authenticate_user!
end

# In views: current_user, user_signed_in?
```

**Best Practices**:
- Use default Devise validations
- Extend with custom hooks in models
- Never bypass `authenticate_user!`
- Store additional user metadata in separate table if needed

### Pundit (Authorization)

**Purpose**: Policy-based authorization (what can users do?)

**Setup**:
```ruby
# Gemfile
gem 'pundit', '~> 2.3'

# Initializer
rails generate pundit:install
```

**Usage**:
```ruby
# app/policies/post_policy.rb
class PostPolicy
  attr_reader :user, :record
  
  def initialize(user, record)
    @user = user
    @record = record
  end
  
  def create?
    user.present?
  end
  
  def update?
    user == record.author || user.admin?
  end
  
  def destroy?
    user.admin?
  end
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Pundit::Authorization
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :check_authorization
  
  def edit
    authorize @post
  end
  
  def update
    authorize @post
    @post.update(post_params)
  end
  
  private
  
  def check_authorization
    authorize Post
  end
end

# In views: policy(@post).update?
```

**Best Practices**:
- One policy per model
- Keep policies focused on authorization logic only
- Test policies separately
- Use `authorize` in controllers before action

---

## 2. Database & Query Optimization

### N+1 Query Detection

**Problem**: Fetching related data inefficiently causes database queries to explode

**Solution - Eager Loading**:
```ruby
# BAD: N+1 query
@posts = Post.all
@posts.each { |post| puts post.author.name }
# Queries: 1 (posts) + N (authors)

# GOOD: Eager load
@posts = Post.includes(:author)
@posts.each { |post| puts post.author.name }
# Queries: 2 (posts, authors)
```

**Gem: Bullet** (detects N+1 queries)

```ruby
# Gemfile
gem 'bullet', group: 'development'

# config/initializers/bullet.rb
if defined?(Bullet)
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.raise = true # Fail in tests
end
```

### Counter Cache

**Purpose**: Avoid COUNT queries on associations

```ruby
# Migration
class AddPostsCountToAuthors < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :posts_count, :integer, default: 0
  end
end

# Model
class Post < ApplicationRecord
  belongs_to :author, counter_cache: true
end

# Usage: author.posts_count (cached, no query)
```

### Kaminari (Pagination)

**Setup**:
```ruby
# Gemfile
gem 'kaminari'

rails generate kaminari:config
```

**Usage**:
```ruby
# Controller
@posts = Post.page(params[:page]).per(20)

# View
<%= paginate @posts %>
```

### Ransack (Search/Filtering)

**Purpose**: Build complex queries from user input safely

**Setup**:
```ruby
# Gemfile
gem 'ransack'
```

**Usage**:
```ruby
# Controller
@q = Post.ransack(params[:q])
@posts = @q.result(distinct: true).page(params[:page])

# View
<%= search_form_for @q do |f| %>
  <%= f.search_field :title_cont, placeholder: "Search title" %>
  <%= f.submit "Search" %>
<% end %>

# Displays posts with title containing search term
```

---

## 3. Testing

### RSpec (Testing Framework)

**Setup**:
```ruby
# Gemfile
group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
end

rails generate rspec:install
```

**Model Spec Example**:
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end
  
  describe 'associations' do
    it { is_expected.to have_many(:posts) }
  end
  
  describe '#full_name' do
    it 'combines first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

**Controller Spec Example**:
```ruby
# spec/controllers/posts_controller_spec.rb
describe PostsController do
  let(:user) { create(:user) }
  let(:post) { create(:post, author: user) }
  
  before { sign_in user }
  
  describe 'GET #index' do
    it 'returns all posts' do
      get :index
      expect(assigns(:posts)).to include(post)
    end
  end
  
  describe 'POST #create' do
    it 'creates new post' do
      expect {
        post :create, params: { post: { title: 'Test' } }
      }.to change(Post, :count).by(1)
    end
  end
end
```

### Factory Bot (Test Data)

**Setup**:
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    first_name { 'John' }
  end
end

# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { 'Test Post' }
    content { 'Test content' }
    author { association :user }
  end
end
```

**Usage in Tests**:
```ruby
let(:user) { create(:user) }
let(:post) { create(:post, author: user) }
let(:posts) { create_list(:post, 3) }
```

### Simplecov (Coverage Tracking)

```ruby
# Gemfile
group :test do
  gem 'simplecov', require: false
end

# spec/rails_helper.rb (at top)
require 'simplecov'
SimpleCov.start 'rails' do
  minimum_coverage 95
  minimum_coverage_by_file 85
end
```

---

## 4. API Development

### Active Model Serializers (JSON Responses)

**Purpose**: Consistent, maintainable JSON responses

**Setup**:
```ruby
# Gemfile
gem 'active_model_serializers'

rails generate serializer user
```

**Usage**:
```ruby
# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :created_at
  
  has_many :posts
  
  attribute :full_name
  
  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end

# Controller (automatic)
@user = User.find(params[:id])
render json: @user
# Returns JSON following serializer structure

# Custom response
render json: @user, serializer: UserSerializer
```

### JSONAPI Serializer (JSONAPI Standard)

**Purpose**: Strict JSONAPI:1.0 specification compliance

```ruby
# Gemfile
gem 'jsonapi-serializer'

# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer
  
  attributes :email, :first_name, :last_name
  has_many :posts
end

# Controller
render json: UserSerializer.new(@user).serializable_hash
```

### Rack CORS (Cross-Origin Requests)

```ruby
# Gemfile
gem 'rack-cors'

# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', 'example.com'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete]
  end
end
```

---

## 5. Background Jobs

### Sidekiq (Job Queue)

**Purpose**: Async job processing for time-consuming tasks

**Setup**:
```ruby
# Gemfile
gem 'sidekiq'
gem 'sidekiq-cron' # For scheduled jobs

# config/sidekiq.yml
:concurrency: 5
:max_retries: 3
:timeout: 25
```

**Usage**:
```ruby
# app/jobs/send_email_job.rb
class SendEmailJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end

# Trigger job
SendEmailJob.perform_later(user.id)
SendEmailJob.set(wait: 1.hour).perform_later(user.id)

# In model callback
class User < ApplicationRecord
  after_create { SendEmailJob.perform_later(id) }
end
```

**Best Practices**:
- Keep jobs small and focused
- Use `perform_later` for async
- Pass IDs not records (records can become stale)
- Handle job failures gracefully
- Monitor queue size

---

## 6. Monitoring & Debugging

### Pry (Interactive Debugging)

```ruby
# Gemfile
group :development do
  gem 'pry-rails'
  gem 'pry-byebug'  # Add `next`, `step`, `continue`
end
```

**Usage**:
```ruby
# In any code, stop execution
binding.pry

# Commands:
# ls - list variables
# pp object - pretty print
# show-source method_name
# continue - resume
```

### Rack MiniProfiler (Performance Profiling)

```ruby
# Gemfile
group :development do
  gem 'rack-mini-profiler'
end

# View in browser: http://localhost:3000/?pp=profile
# Shows: SQL queries, slow methods, memory usage
```

### Sentry (Error Tracking)

```ruby
# Gemfile
gem 'sentry-rails'
gem 'sentry-sidekiq'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environment = Rails.env
end
```

---

## 7. File Handling

### ActiveStorage (File Uploads)

**Purpose**: Attach files to records (images, documents)

**Setup**:
```ruby
rails active_storage:install
rails db:migrate

# config/storage.yml (production)
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  bucket: <%= ENV['AWS_BUCKET'] %>
  region: us-east-1
```

**Usage**:
```ruby
# Model
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :documents
  
  validate :avatar_validation
  
  private
  
  def avatar_validation
    if avatar.present?
      unless avatar.blob.content_type.in?(%w[image/jpeg image/png])
        errors.add(:avatar, 'must be JPEG or PNG')
      end
    end
  end
end

# Controller
def update
  @user.avatar.attach(params[:avatar])
end

# View
<%= image_tag @user.avatar, alt: 'Avatar' if @user.avatar.present? %>
```

### Paperclip (Legacy Alternative)

Not recommended for new projects; use ActiveStorage instead.

---

## 8. Pagination & Search

### Kaminari (Recommended)

See [Database & Query Optimization](#2-database--query-optimization)

### Will Paginate (Alternative)

```ruby
# Gemfile
gem 'will_paginate'

# Controller
@posts = Post.paginate(page: params[:page], per_page: 20)

# View
<%= will_paginate @posts %>
```

---

## 9. Performance & Caching

### Rails Caching

```ruby
# Fragment caching (cache view parts)
<% cache @post do %>
  <%= render @post %>
<% end %>

# Query caching
@author = Rails.cache.fetch("author_#{id}", expires_in: 1.hour) do
  Author.find(id)
end

# Key-based expiration
Rails.cache.write('user_1_profile', data, expires_in: 1.day)
Rails.cache.delete('user_1_profile')
```

### Redis (Cache Store)

```ruby
# Gemfile
gem 'redis'

# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  namespace: 'cache',
  expires_in: 1.day
}
```

### Image Optimization

**Gem: ImageProcessing**:
```ruby
# Gemfile
gem 'image_processing', '~> 1.2'

# Resize images
user.avatar.variant(resize_to_limit: [300, 300])
```

---

## 10. Serialization

### JSON Serialization

See [API Development](#4-api-development)

### CSV Export

```ruby
# Gemfile
gem 'csv' # Built-in for Rails 6+

# app/models/post.rb
scope :to_csv, -> {
  CSV.generate do |csv|
    csv << column_names
    all.each { |post| csv << post.attributes.values }
  end
}

# Controller
respond_to do |format|
  format.html
  format.csv { send_data Post.to_csv, filename: "posts-#{Date.today}.csv" }
end
```

### XML Support

```ruby
# Built into Rails
render xml: @user.to_xml(include: :posts)
```

## 11. Administration

### Analysis
Administrate is a Rails engine designed to generate admin dashboards, providing interfaces to create, edit, search, and delete records for any model in a Rails application. It's known for its flexibility and ease of customization using standard Rails controllers and views, rather than relying on DSLs (Domain Specific Languages).
While Administrate itself does not directly provide a built-in role-based access control (RBAC) system, it is highly customizable and allows developers to implement their own authorization logic. You can integrate authentication and authorization within the Admin::ApplicationController, which all Administrate controllers inherit from. This means you can leverage existing authentication systems (like Devise) and add authorization checks based on your user's roles (e.g., staff, managers, admin).
For instance, you can define a before_action in Admin::ApplicationController to check if the current_user has the necessary admin role before allowing access to the dashboard. You could extend this logic to check for specific roles (manager, staff) for different sections or actions within the admin panel.

### Recommendation
Adding thoughtbot/administrate would likely be a good way to expand on your existing roles with specific access to different admin panels for managing users, budget targets, rosters, and clocking in/out.

Here's why:

- Customizable Authorization: You can integrate your existing authentication system and implement granular role-based access control within Admin::ApplicationController to restrict access to specific models or actions based on your staff, managers, and admin roles.
- Resource Management: Administrate automatically generates dashboards for your ActiveRecord models, allowing you to create, edit, search, and delete records. This would seamlessly cover managing users, budget targets, and other models related to rosters and clock-in/out.
- Standard Rails Practices: The gem encourages using standard Rails controllers and views for customization, making it easier for you to tailor the admin interface to your specific needs for each role without learning a new DSL.
- Flexible Interface: You can customize which attributes are displayed, how they are displayed, and even add custom actions or field types to suit the unique requirements of each role's administrative tasks. For example, you could have different views or editable fields for a manager editing a budget versus a staff member viewing their roster.

Steps to consider for implementation:

1. Install administrate: Add gem 'administrate' to your Gemfile and run bundle install, then `rails generate administrate:install`.
2. Authentication Integration: Configure Admin::ApplicationController to use your existing authentication system (e.g., `before_action :authenticate_user!`).
2. Authorization Logic: Implement before_action filters in Admin::ApplicationController or specific Admin:: controllers to check user roles (e.g., `current_user.has_role?(:admin)` or current_user.manager?) and redirect unauthorized users.
4. Dashboard Customization: Generate dashboards for your User, Roster, Budget, and other relevant models. Customize these dashboards (app/dashboards/*.rb) to control which attributes are visible and editable for different roles.
5. View Customization: If specific roles require vastly different interfaces or actions, you can override Administrate's default views and partials with your own custom Rails views.

---

## Quick Reference: When to Load This File

**AGENTS.md mentions**: "For gem-specific patterns, see gems.md"

**Load gems.md when**:
- Agent/user asks: "How do I use [gem name]?"
- Planning integration with external gem
- Need pattern for gem-based feature
- Troubleshooting gem-related issues
- Comparing gem alternatives

**Don't load unless needed** → keeps context lean, tokens efficient

---

## Adding New Gems: Checklist

Before adding a gem to your Rails project:

1. ✅ **Does Rails provide this?** (Check first)
2. ✅ **Is it actively maintained?** (Check GitHub stars, recent commits)
3. ✅ **Does it add significant value?** (Avoid gems for small features)
4. ✅ **Security audit**: `bundle audit`
5. ✅ **Add to Gemfile with version lock**: `gem 'name', '~> 1.2'`
6. ✅ **Run `bundle install` and commit `Gemfile.lock`**
7. ✅ **Run generator/setup if needed**: `rails generate [gem]:install`
8. ✅ **Add to docs if non-obvious usage**: Update README or architecture docs

---

**Keep gems.md updated as your project evolves.**  
**Reference this file from AGENTS.md when gem-specific guidance is needed.**

**Let's stay efficient with our tokens! 🚀**
