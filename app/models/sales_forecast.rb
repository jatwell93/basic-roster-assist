# == Schema Information
# Manages sales forecasts with user association, date ranges, forecast types, and confidence levels
class SalesForecast < ApplicationRecord
  enum :forecast_type, { weekly: 0, fortnightly: 1, monthly: 2 }

  belongs_to :user

  validates :forecast_type, presence: true
  validates :start_date, :end_date, presence: true
  validates :projected_sales, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :actual_sales, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :confidence_level, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validate :end_after_start

  # Calculate variance between actual and projected sales
  def variance
    return 0 if actual_sales.nil?
    actual_sales - projected_sales
  end

  # Calculate variance as a percentage of projected sales
  def variance_percentage
    return 0 if actual_sales.nil? || projected_sales.zero?
    ((actual_sales - projected_sales) / projected_sales * 100).round(1)
  end

  # Calculate accuracy percentage (how close actual was to projected)
  def accuracy
    return 0 if actual_sales.nil? || projected_sales.zero?
    (actual_sales / projected_sales * 100).round(1)
  end

  private

  def end_after_start
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
