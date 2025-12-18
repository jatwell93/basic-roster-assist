require 'rails_helper'

RSpec.describe WageReportGenerator do
  let(:start_date) { 1.week.ago.beginning_of_week }
  let(:end_date) { 1.week.ago.end_of_week }
  let(:user) { create(:user, hourly_rate: 25.50) }
  let(:other_user) { create(:user, hourly_rate: 30.00) }

  describe '#generate_csv' do
    context 'when users have time entries within date range' do
      before do
        # Create time entries for user within date range
        create(:time_entry,
               user: user,
               clock_in: start_date + 1.day + 9.hours,
               clock_out: start_date + 1.day + 17.hours) # 8 hours

        create(:time_entry,
               user: user,
               clock_in: start_date + 2.days + 9.hours,
               clock_out: start_date + 2.days + 17.hours) # 8 hours

        # Create time entry for other user
        create(:time_entry,
               user: other_user,
               clock_in: start_date + 3.days + 9.hours,
               clock_out: start_date + 3.days + 17.hours) # 8 hours
      end

      it 'generates CSV with correct headers' do
        service = described_class.new(start_date: start_date, end_date: end_date)
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        headers = lines.first.split(',')

        expect(headers).to include('User ID')
        expect(headers).to include('User Name')
        expect(headers).to include('Total Hours')
        expect(headers).to include('Hourly Rate')
        expect(headers).to include('Total Wages')
      end

      it 'calculates wages correctly' do
        service = described_class.new(start_date: start_date, end_date: end_date)
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        data_lines = lines[1..] # Skip header

        # Should have 2 data rows (one for each user)
        expect(data_lines.size).to eq(2)

        # Parse first user's data
        user_data = data_lines.find { |line| line.include?(user.id.to_s) }
        expect(user_data).to be_present

        fields = user_data.split(',')
        total_hours = fields[2].to_f
        hourly_rate = fields[3].to_f
        total_wages = fields[4].to_f

        expect(total_hours).to eq(16.0) # 8 + 8 hours
        expect(hourly_rate).to eq(25.50)
        expect(total_wages).to eq(408.0) # 16 * 25.50
      end

      it 'includes all users with time entries' do
        service = described_class.new(start_date: start_date, end_date: end_date)
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        data_lines = lines[1..] # Skip header

        user_ids = data_lines.map { |line| line.split(',')[0] }
        expect(user_ids).to include(user.id.to_s)
        expect(user_ids).to include(other_user.id.to_s)
      end
    end

    context 'when no time entries exist in date range' do
      it 'returns CSV with only headers' do
        service = described_class.new(start_date: start_date, end_date: end_date)
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        expect(lines.size).to eq(1) # Only header row
        expect(lines.first).to include('User ID')
      end
    end

    context 'with user filter' do
      before do
        create(:time_entry,
               user: user,
               clock_in: start_date + 1.day + 9.hours,
               clock_out: start_date + 1.day + 17.hours)

        create(:time_entry,
               user: other_user,
               clock_in: start_date + 2.days + 9.hours,
               clock_out: start_date + 2.days + 17.hours)
      end

      it 'filters results to specified users' do
        service = described_class.new(
          start_date: start_date,
          end_date: end_date,
          user_ids: [user.id]
        )
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        data_lines = lines[1..] # Skip header

        expect(data_lines.size).to eq(1)
        expect(data_lines.first).to include(user.id.to_s)
        expect(data_lines.first).not_to include(other_user.id.to_s)
      end
    end

    context 'with invalid date range' do
      it 'raises an error when start_date is after end_date' do
        expect {
          described_class.new(start_date: end_date, end_date: start_date)
        }.to raise_error(ArgumentError, 'Start date must be before end date')
      end

      it 'raises an error when dates are nil' do
        expect {
          described_class.new(start_date: nil, end_date: end_date)
        }.to raise_error(ArgumentError, 'Start date and end date are required')
      end
    end

    context 'with time entries outside date range' do
      before do
        # Create time entry outside the date range
        create(:time_entry,
               user: user,
               clock_in: 2.weeks.ago + 9.hours,
               clock_out: 2.weeks.ago + 17.hours)
      end

      it 'excludes time entries outside date range' do
        service = described_class.new(start_date: start_date, end_date: end_date)
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        expect(lines.size).to eq(1) # Only header, no data rows
      end
    end

    context 'with incomplete time entries' do
      before do
        # Create time entry without clock_out (ongoing)
        create(:time_entry,
               user: user,
               clock_in: start_date + 1.day + 9.hours,
               clock_out: nil)
      end

      it 'excludes incomplete time entries from calculations' do
        service = described_class.new(start_date: start_date, end_date: end_date)
        csv_content = service.generate_csv

        lines = csv_content.split("\n")
        expect(lines.size).to eq(1) # Only header, no data rows
      end
    end
  end
end