FactoryBot.define do
  factory :user do
    email { "test#{rand(1000)}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    hourly_rate { 25.50 }
  end
end
