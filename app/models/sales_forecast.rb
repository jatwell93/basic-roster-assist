# == Schema Information
# Manages sales forecasts with user association, date ranges, forecast types, and confidence levels
class SalesForecast < ApplicationRecord
  enum :forecast_type, { weekly: 0, fortnightly: 1, monthly: 2 }

  belongs_to :user

  validates :forecast_type, presence: true
  validates :start_date, :end_date, presence: true
  validates :projected_sales, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :actual_sales, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :confidence_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  validate :end_after_start

  private

  def end_after_start
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
