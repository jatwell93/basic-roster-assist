class WeeklyRoster < ApplicationRecord
  belongs_to :base_roster
  belongs_to :user
  has_many :weekly_shifts, dependent: :destroy

  enum :week_type, { weekly: 0, fortnightly: 1 }
end
