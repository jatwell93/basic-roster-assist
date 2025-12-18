class WageReportGenerator
  def initialize(start_date:, end_date:, user_ids: nil)
    @start_date = start_date
    @end_date = end_date
    @user_ids = user_ids

    validate_dates!
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << [
        "User ID",
        "User Name",
        "Total Hours",
        "Hourly Rate",
        "Total Wages"
      ]

      # Get time entries within date range, grouped by user
      time_entries = TimeEntry.completed
        .where("DATE(clock_in) >= ? AND DATE(clock_in) <= ?", @start_date, @end_date)
        .includes(:user)
        .order("clock_in ASC")

      if @user_ids.present?
        time_entries = time_entries.where(user_id: @user_ids)
      end

      # Group by user and calculate totals
      user_totals = {}
      time_entries.each do |entry|
        user_id = entry.user.id
        user_totals[user_id] ||= {
          user: entry.user,
          total_hours: 0.0,
          total_wages: 0.0
        }

        user_totals[user_id][:total_hours] += entry.hours_worked
        user_totals[user_id][:total_wages] += entry.wage_amount
      end

      # Output each user's totals
      user_totals.each do |user_id, data|
        csv << [
          data[:user].id,
          data[:user].email,
          format("%.2f", data[:total_hours]),
          format("%.2f", data[:user].hourly_rate),
          format("%.2f", data[:total_wages])
        ]
      end
    end
  end

  private

  def validate_dates!
    raise ArgumentError, "Start date and end date are required" unless @start_date && @end_date
    raise ArgumentError, "Start date must be before end date" unless @start_date < @end_date
  end
end
