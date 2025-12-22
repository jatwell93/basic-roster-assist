FactoryBot.define do
  factory :award_rate do
    user
    award_code { "HOSPITALITY" }
    classification { "Level 1" }
    rate { 25.00 }
    effective_date { Date.current }

    trait :expired do
      effective_date { 1.month.ago }
    end

    trait :future do
      effective_date { 1.month.from_now }
    end
  end
end
