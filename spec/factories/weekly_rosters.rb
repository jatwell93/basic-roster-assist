FactoryBot.define do
  factory :weekly_roster do
    name { "Weekly Roster" }
    week_start_date { Date.current.beginning_of_week }
    week_end_date { Date.current.beginning_of_week + 6.days }
    week_type { :weekly }
    base_roster
    user
  end
end
