FactoryBot.define do
  factory :base_roster do
    name { "Test Roster" }
    starts_at { Date.current }
    ends_at { Date.current + 7.days }
    week_type { :weekly }
    user
  end
end
