# == Schema Information
# Manages roster templates with user association, date ranges, and week type enums
class BaseRoster < ApplicationRecord
  enum :week_type, { weekly: 0, fortnightly: 1 }

  belongs_to :user
  has_many :base_shifts, dependent: :destroy

  validates :name, presence: true
  validates :starts_at, :ends_at, :week_type, presence: true

  validate :end_after_start

  private

  def end_after_start
    return unless starts_at && ends_at

    if ends_at < starts_at
      errors.add(:ends_at, "must be after start date")
    end
  end
end
