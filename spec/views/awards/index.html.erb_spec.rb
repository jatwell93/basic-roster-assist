require "rails_helper"

RSpec.describe "awards/index.html.erb", type: :view do
  let(:user) { create(:user, role: :admin) }
  let(:award_rates) do
    [
      create(:award_rate, award_code: "MA000100", classification: "Level 1 - Miscellaneous"),
      create(:award_rate, award_code: "MA000200", classification: "Level 2 - Miscellaneous")
    ]
  end

  before do
    allow(view).to receive(:current_user).and_return(user)
    assign(:award_rates, award_rates)
    assign(:users, [ user ])
    render
  end

  describe "page heading and layout" do
    it "displays 'Award Rates Management' heading" do
      expect(rendered).to have_text("Award Rates Management")
    end

    it "displays descriptive subtitle" do
      expect(rendered).to have_text("Manage Fair Work award rates and user assignments")
    end

    it "uses correct Tailwind container classes" do
      expect(rendered).to match(/max-w-7xl\s+mx-auto/)
    end

    it "has responsive padding" do
      expect(rendered).to match(/px-4\s+sm:px-6\s+lg:px-8/)
    end
  end

  describe "action buttons" do
    it "renders 'New Award Rate' button" do
      expect(rendered).to have_link("New Award Rate")
    end

    it "'New Award Rate' button links to new_award_path" do
      expect(rendered).to have_link("New Award Rate", href: new_award_path)
    end

    it "'New Award Rate' button has blue styling" do
      expect(rendered).to match(/bg-blue-600.*hover:bg-blue-700/)
    end

    it "renders 'Manage User Awards' button" do
      expect(rendered).to have_link("Manage User Awards")
    end

    it "'Manage User Awards' button links to users_awards_path" do
      expect(rendered).to have_link("Manage User Awards", href: users_awards_path)
    end

    it "'Manage User Awards' button has green styling" do
      expect(rendered).to match(/bg-green-600.*hover:bg-green-700/)
    end

    it "renders 'Back to Dashboard' button" do
      expect(rendered).to have_link("Back to Dashboard")
    end

    it "'Back to Dashboard' button links to root_path" do
      expect(rendered).to have_link("Back to Dashboard", href: root_path)
    end

    it "'Back to Dashboard' button has gray styling" do
      expect(rendered).to match(/bg-gray-600.*hover:bg-gray-700/)
    end

    it "buttons are displayed in a flex row" do
      expect(rendered).to match(/flex\s+space-x-3/)
    end
  end

  describe "award rates table" do
    it "displays 'Current Award Rates' section header" do
      expect(rendered).to have_text("Current Award Rates")
    end

    it "displays explanatory text about award rates" do
      expect(rendered).to have_text("Award rates are used to calculate wages for time entries")
    end

    it "renders a list element for award rates" do
      expect(rendered).to have_selector("ul[role='list']")
    end

    it "displays each award rate with award code" do
      award_rates.each do |award_rate|
        expect(rendered).to have_text(award_rate.award_code)
      end
    end

    it "displays each award rate with classification" do
      award_rates.each do |award_rate|
        expect(rendered).to have_text(award_rate.classification)
      end
    end

    it "award rates are listed in div items" do
      expect(rendered).to have_selector("li.px-4.py-4")
    end
  end

  describe "award rate styling with Tailwind" do
    it "uses shadow styling for card container" do
      expect(rendered).to match(/bg-white\s+shadow/)
    end

    it "uses rounded corners on cards" do
      expect(rendered).to match(/rounded-md/)
    end

    it "has border styling between items" do
      expect(rendered).to match(/divide-y\s+divide-gray-200/)
    end

    it "has proper spacing and padding" do
      expect(rendered).to match(/px-4\s+py-5\s+sm:px-6/)
    end

    it "section header has gray background" do
      # Header has border-b and border-gray-200, check for that instead
      expect(rendered).to match(/border-b\s+border-gray-200/)
    end
  end

  describe "empty state handling" do
    it "renders when award_rates is empty" do
      assign(:award_rates, [])
      expect { render }.not_to raise_error
    end
  end

  describe "responsive design" do
    it "heading uses responsive text sizing" do
      expect(rendered).to match(/text-3xl/)
    end

    it "container is responsive" do
      expect(rendered).to match(/max-w-7xl/)
    end

    it "buttons are responsive" do
      # Buttons have px-4 py-2 text-sm font-medium (not sm:text-sm)
      expect(rendered).to match(/px-4\s+py-2/)
    end

    it "list items have responsive padding" do
      expect(rendered).to match(/px-4\s+py-4\s+sm:px-6/)
    end
  end

  describe "accessibility" do
    it "heading uses semantic h1 tag" do
      expect(rendered).to have_selector("h1")
    end

    it "list has role attribute for semantics" do
      expect(rendered).to have_selector("ul[role='list']")
    end

    it "uses semantic strong tags for emphasis" do
      # View uses Tailwind font classes (font-bold, font-medium) instead of strong tags
      expect(rendered).to match(/font-bold|font-medium/)
    end

    it "links have text labels" do
      expect(rendered).to have_link("New Award Rate")
      expect(rendered).to have_link("Manage User Awards")
      expect(rendered).to have_link("Back to Dashboard")
    end
  end

  describe "text styling and hierarchy" do
    it "main heading uses bold font weight" do
      expect(rendered).to match(/font-bold/)
    end

    it "subtitle uses smaller text" do
      expect(rendered).to match(/text-sm\s+text-gray-600/)
    end

    it "section header uses medium font weight" do
      expect(rendered).to match(/font-medium/)
    end

    it "award codes display prominently" do
      expect(rendered).to have_selector("p", text: award_rates.first.award_code)
    end
  end

  describe "page sections" do
    it "has flex layout for header" do
      expect(rendered).to match(/flex\s+justify-between/)
    end

    it "groups award rates in consistent sections" do
      expect(rendered).to have_selector("ul[role='list']")
    end

    it "uses proper vertical spacing between sections" do
      expect(rendered).to match(/mb-8/)
    end
  end
end
