class WeeklyRoster < ApplicationRecord
  belongs_to :base_roster
  belongs_to :user
  belongs_to :finalized_by, class_name: "User", optional: true
  has_many :weekly_shifts, dependent: :destroy

  enum :week_type, { weekly: 0, fortnightly: 1 }
  enum :status, { draft: 0, finalized: 1 }

  validates :status, presence: true

  scope :drafted, -> { where(status: :draft) }
  scope :finalized_rosters, -> { where(status: :finalized) }

  # Finalize roster and send emails to all assigned staff
  def finalize!(current_user)
    return false if finalized?

    transaction do
      update!(status: :finalized, finalized_at: Time.current, finalized_by: current_user)

      # Get unique staff assigned to shifts
      assigned_staff_ids = weekly_shifts.select(:assigned_staff_id).distinct.pluck(:assigned_staff_id).compact
      assigned_staff_ids.each do |staff_id|
        staff = User.find(staff_id)
        staff_shifts = weekly_shifts.where(assigned_staff_id: staff_id).to_a
        RosterMailer.send_shifts(self, staff, staff_shifts).deliver_later
      end
    end
  end

  # Mark shift as changed and resend email to affected staff
  def notify_shift_change(shift, old_shift_data)
    return unless finalized?

    RosterMailer.shift_changed(shift, old_shift_data, shift.assigned_staff).deliver_later if shift.assigned_staff
  end

  # Check if roster can still be edited
  def editable?
    !finalized?
  end
end
