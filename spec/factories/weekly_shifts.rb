FactoryBot.define do
  factory :weekly_shift do
    day_of_week { :monday }
    shift_type { :morning }
    start_time { '08:00' }
    end_time { '16:00' }
    weekly_roster
  end
end