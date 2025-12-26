class WeeklyShift < ApplicationRecord
  belongs_to :weekly_roster

  enum :day_of_week, { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum :shift_type, { morning: 0, afternoon: 1, evening: 2, night: 3 }
end
