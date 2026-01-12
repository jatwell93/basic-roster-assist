FactoryBot.define do
  factory :work_section do
    name { "MyString" }
    association :user
  end
end
