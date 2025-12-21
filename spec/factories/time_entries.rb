FactoryBot.define do
  factory :time_entry do
    association :user
    clock_in { 1.hour.ago }
    clock_out { nil }

    trait :completed do
      clock_out { Time.current }
    end

    trait :invalid do
      clock_in { Time.current }
      clock_out { 1.hour.ago }
    end
  end
end
