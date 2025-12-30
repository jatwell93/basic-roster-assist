require 'rails_helper'

RSpec.describe "awards/users.html.tailwindcss", type: :view do
  let(:admin_user) { create(:user, :admin) }
  let(:user_with_awards) { create(:user, name: 'John Doe') }
  let(:user_without_awards) { create(:user, name: 'Jane Smith') }
  let(:award1) { create(:award_rate, user: user_with_awards, award_code: 'TEST001', classification: 'Level 1') }
  let(:award2) { create(:award_rate, user: user_with_awards, award_code: 'TEST002', classification: 'Level 2') }

  before do
    assign(:users, [user_with_awards, user_without_awards])
    assign(:award_rates, [award1, award2])
    sign_in admin_user
  end

  it "displays the page title" do
    render
    expect(rendered).to have_selector('h1', text: 'User Award Assignments')
  end

  it "displays the page description" do
    render
    expect(rendered).to have_selector('p', text: 'Manage Fair Work award assignments for staff members')
  end

  it "displays navigation links" do
    render
    expect(rendered).to have_link('Award Rates', href: awards_path)
    expect(rendered).to have_link('Back to Dashboard', href: root_path)
  end

  it "displays all users" do
    render
    expect(rendered).to have_content('John Doe')
    expect(rendered).to have_content('Jane Smith')
  end

  it "displays user email addresses" do
    render
    expect(rendered).to have_content(user_with_awards.email)
    expect(rendered).to have_content(user_without_awards.email)
  end

  it "displays award assignments for users with awards" do
    render
    expect(rendered).to have_content('TEST001 - Level 1')
    expect(rendered).to have_content('TEST002 - Level 2')
  end

  it "displays 'No award assigned' for users without awards" do
    render
    expect(rendered).to have_content('No award assigned')
  end

  it "displays 'Manage Awards' link for each user" do
    render
    expect(rendered).to have_selector('a[data-action="manage-awards"]', count: 2)
  end

  it "displays award rates with formatted currency" do
    render
    expect(rendered).to have_content('$25.00') # Assuming award1.rate is 25.0
    expect(rendered).to have_content('$30.00') # Assuming award2.rate is 30.0
  end

  context "when there are no users" do
    before do
      assign(:users, [])
      assign(:award_rates, [])
    end

    it "displays empty state message" do
      render
      expect(rendered).to have_content('No users found')
      expect(rendered).to have_content('Users will appear here once they are added to the system')
    end
  end

  it "includes JavaScript for award management functionality" do
    render
    expect(rendered).to include('Award management functionality coming soon!')
  end
end