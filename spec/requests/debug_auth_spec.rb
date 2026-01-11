require 'rails_helper'

RSpec.describe "Auth Debug", type: :request do
  let(:user) { create(:user) }

  it "works with sign_in" do
    sign_in user
    get root_path
    expect(response).to be_successful
  end

  it "works with login_as" do
    login_as user, scope: :user
    get root_path
    expect(response).to be_successful
  end
end
