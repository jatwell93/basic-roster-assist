class TimeEntry < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true

  validate :clock_out_after_clock_in, if: :clock_out?

  # Business logic methods
  def duration
    return nil unless clock_out && clock_in

    (clock_out - clock_in).to_i
  end

  def ongoing?
    clock_out.nil?
  end

  def completed?
    clock_out.present?
  end

  private

  def clock_out_after_clock_in
    return unless clock_in && clock_out

    if clock_out <= clock_in
      errors.add(:clock_out, "must be after clock in")
    end
  end
end
