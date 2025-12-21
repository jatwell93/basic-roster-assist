FactoryBot.define do
  factory :sales_forecast do
    forecast_type { :weekly }
    start_date { Date.current }
    end_date { Date.current + 7.days }
    projected_sales { 1000.00 }
    actual_sales { nil }
    confidence_level { 75 }
    user
  end

  trait :fortnightly do
    forecast_type { :fortnightly }
    start_date { Date.current }
    end_date { Date.current + 14.days }
  end

  trait :monthly do
    forecast_type { :monthly }
    start_date { Date.current }
    end_date { Date.current.end_of_month }
  end

  trait :with_actual_sales do
    actual_sales { 1200.00 }
  end

  trait :high_confidence do
    confidence_level { 90 }
  end

  trait :low_confidence do
    confidence_level { 30 }
  end
end
