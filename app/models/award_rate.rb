class AwardRate < ApplicationRecord
  belongs_to :user, optional: true

  # Validations
  validates :award_code, presence: true, length: { minimum: 2 }
  validates :classification, presence: true
  validates :rate, presence: true, numericality: { greater_than: 0, precision: 8, scale: 2 }
  validates :effective_date, presence: true

  # Scopes
  scope :active, -> { where("effective_date <= ?", Date.current) }
  scope :by_award_code, ->(code) { where(award_code: code) }
  scope :for_user, ->(user) { where(user: user) }
  scope :current, -> { where(effective_date: Date.current.all_month) }

  # Methods for Fair Work API integration
  def self.fetch_and_update_rates_for_user(user, award_code, classification)
    service = FairWorkApiService.new
    result = service.fetch_award_rate(award_code)

    if result.success?
      # Create or update the award rate
      award_rate = user.award_rates.find_or_initialize_by(
        award_code: award_code,
        classification: classification
      )

      award_rate.rate = result.rate
      award_rate.effective_date = Date.current
      award_rate.save!

      award_rate
    else
      Rails.logger.error("Failed to fetch award rate for #{award_code}: #{result.error}")
      nil
    end
  end

  def self.update_all_rates_from_api
    # Update rates for all users with award assignments
    users_with_awards = User.joins(:award_rates).distinct

    users_with_awards.each do |user|
      user.award_rates.each do |award_rate|
        fetch_and_update_rates_for_user(
          user,
          award_rate.award_code,
          award_rate.classification
        )
      end
    end
  end
end
