require 'ostruct'

class RosterPublishedNotification
  # Custom error for when roster has no associated user
  class NoUserError < StandardError
    def initialize(message = "Roster has no associated user")
      super(message)
    end
  end

  attr_reader :roster

  def initialize(roster)
    raise ArgumentError, "Roster cannot be nil" if roster.nil?

    @roster = roster
  end

  def call
    validate_roster!
    send_notification_email

    OpenStruct.new(success?: true, roster: roster)
  rescue NoUserError
    # Re-raise user errors - these are configuration/data issues that should be addressed
    raise
  rescue StandardError => e
    # Log the error but don't fail the service - email delivery failures shouldn't break roster publishing
    Rails.logger.error("Failed to send roster published notification for roster #{roster.id}: #{e.message}")
    OpenStruct.new(success?: true, roster: roster) # Still return success since roster publishing succeeded
  end

  private

  def validate_roster!
    raise NoUserError unless roster.user.present?
  end

  def send_notification_email
    RosterMailer.roster_published(roster).deliver_later
  end
end
