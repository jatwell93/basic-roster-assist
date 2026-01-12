# == Schema Information
# Manages roster templates with user association, date ranges, and week type enums
class BaseRoster < ApplicationRecord
  enum :week_type, { weekly: 0, fortnightly: 1 }

  belongs_to :user
  has_many :base_shifts, dependent: :destroy

  validates :name, presence: true
  validates :starts_at, :ends_at, :week_type, presence: true
  validates :weekly_sales_forecast, numericality: { greater_than: 0 }, allow_nil: true
  validates :opening_time, :closing_time, presence: true, if: -> { opening_time.present? || closing_time.present? }
  validate :end_after_start
  validate :closing_after_opening
  
  before_validation :set_defaults
  
  def wage_percentage
    target_wage_percentage || user.wage_percentage_goal || 15.0
  end

  private
  
  def set_defaults
    self.opening_time ||= "09:00"
    self.closing_time ||= "17:00"
    self.interval_minutes ||= 30
    self.estimated_hourly_rate ||= user&.hourly_rate || 25.0
  end

  def closing_after_opening
    return unless opening_time && closing_time
    
    if closing_time <= opening_time
      errors.add(:closing_time, "must be after opening time")
    end
  end

  def end_after_start
    return unless starts_at && ends_at

    if ends_at < starts_at
      errors.add(:ends_at, "must be after start date")
    end
  end
end
