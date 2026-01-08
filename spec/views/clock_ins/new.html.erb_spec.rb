require "rails_helper"

RSpec.describe "clock_ins/new.html.erb", type: :view do
  let(:user) { create(:user, role: :staff) }

  before do
    render
  end

  describe "page structure" do
    it "renders the page heading" do
      expect(rendered).to have_text("Staff Clock In/Out")
    end

    it "renders the subheading with PIN instructions" do
      expect(rendered).to have_text("Enter your PIN to clock in or out")
    end

    it "has a min-height full screen container with centered layout" do
      expect(rendered).to match(/min-h-screen.*flex.*justify-center/)
    end

    it "uses gray-50 background color" do
      expect(rendered).to match(/bg-gray-50/)
    end
  end

  describe "clock in form" do
    it "renders a form element" do
      expect(rendered).to have_selector("form")
    end

    it "form submits to clock_in_path via POST" do
      expect(rendered).to match(/action=".*clock_in"/)  # clock_in_path renders as /clock_in
      expect(rendered).to match(/method="post"/)
    end

    it "renders a PIN password field" do
      expect(rendered).to have_field("pin", type: "password")
    end

    it "PIN field is required" do
      expect(rendered).to match(/required/)
    end

    it "PIN field has placeholder text" do
      expect(rendered).to have_field("pin", placeholder: "Enter your PIN")
    end

    it "PIN field has maxlength of 10" do
      expect(rendered).to match(/maxlength="10"/)
    end

    it "PIN field accepts only numeric input" do
      expect(rendered).to match(/pattern="\[0-9\]\*"/)
    end

    it "PIN field has numeric inputmode" do
      expect(rendered).to match(/inputmode="numeric"/)
    end

    it "PIN field autocomplete is off" do
      expect(rendered).to match(/autocomplete="off"/)
    end
  end

  describe "form styling with Tailwind CSS" do
    it "form has spacing classes" do
      expect(rendered).to match(/mt-8\s+space-y-6/)
    end

    it "PIN field has border styling" do
      expect(rendered).to match(/border.*border-gray-300/)
    end

    it "PIN field has focus ring styling" do
      expect(rendered).to match(/focus:outline-none.*focus:ring-blue-500/)
    end

    it "PIN field has placeholder styling" do
      expect(rendered).to match(/placeholder-gray-500/)
    end

    it "PIN field has text color" do
      expect(rendered).to match(/text-gray-900/)
    end
  end

  describe "submit button" do
    it "renders a submit button" do
      expect(rendered).to have_button("Submit")
    end

    it "submit button has primary blue styling" do
      expect(rendered).to match(/bg-blue-600.*hover:bg-blue-700/)
    end

    it "submit button has white text" do
      expect(rendered).to match(/text-white/)
    end

    it "submit button is full width" do
      expect(rendered).to match(/w-full/)
    end

    it "submit button has focus ring" do
      expect(rendered).to match(/focus:ring-2.*focus:ring-blue-500/)
    end

    it "submit button has disabled state styling" do
      expect(rendered).to match(/disabled:opacity-50.*disabled:cursor-not-allowed/)
    end
  end

  describe "accessibility" do
    it "PIN field has an associated label" do
      # Label is marked sr-only (screen reader only), check for selector instead
      expect(rendered).to have_selector("label[for='pin']")
    end

    it "PIN label is hidden from screen (sr-only)" do
      expect(rendered).to match(/sr-only/)
    end

    it "uses semantic HTML form elements" do
      expect(rendered).to have_selector("form")
      expect(rendered).to have_field("pin")
      expect(rendered).to have_button
    end
  end

  describe "responsive design" do
    it "container has responsive padding" do
      expect(rendered).to match(/px-4\s+sm:px-6\s+lg:px-8/)
    end

    it "form width is responsive" do
      expect(rendered).to match(/max-w-md\s+w-full/)
    end

    it "heading has responsive text size" do
      expect(rendered).to match(/text-3xl/)
    end
  end

  describe "layout structure" do
    it "has centered container" do
      expect(rendered).to match(/flex\s+items-center\s+justify-center/)
    end

    it "uses flexbox for vertical spacing" do
      expect(rendered).to match(/space-y-8/)
    end

    it "rounded corners on input elements" do
      expect(rendered).to match(/rounded-md/)
    end
  end
end
