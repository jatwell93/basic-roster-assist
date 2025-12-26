require 'rails_helper'

RSpec.describe WeeklyRosterGenerationService, type: :service do
  let(:user) { create(:user) }
  let(:base_roster) { create(:base_roster, user: user, name: 'Summer Schedule', week_type: :weekly) }
  
  before do
    # Create base shifts for the roster
    create(:base_shift,
            base_roster: base_roster,
            day_of_week: 'monday',
            start_time: '09:00',
            end_time: '17:00',
            shift_type: 'morning')
    
    create(:base_shift,
            base_roster: base_roster,
            day_of_week: 'tuesday',
            start_time: '14:00',
            end_time: '22:00',
            shift_type: 'afternoon')
    
    create(:base_shift,
            base_roster: base_roster,
            day_of_week: 'wednesday',
            start_time: '18:00',
            end_time: '02:00',
            shift_type: 'evening')
  end

  describe '#generate' do
    context 'with valid base roster' do
      let(:week_start_date) { Date.current.beginning_of_week }
      
      it 'creates weekly roster with correct attributes' do
        service = described_class.new(base_roster: base_roster, week_start_date: week_start_date)
        weekly_roster = service.generate
        
        expect(weekly_roster).to be_persisted
        expect(weekly_roster.name).to eq('Summer Schedule')
        expect(weekly_roster.week_start_date).to eq(week_start_date)
        expect(weekly_roster.week_end_date).to eq(week_start_date + 6.days)
        expect(weekly_roster.week_type).to eq('weekly')
        expect(weekly_roster.base_roster).to eq(base_roster)
        expect(weekly_roster.user).to eq(user)
      end

      it 'creates weekly shifts based on base shifts' do
        service = described_class.new(base_roster: base_roster, week_start_date: week_start_date)
        weekly_roster = service.generate
        
        expect(weekly_roster.weekly_shifts.count).to eq(3)
        
        # Check Monday shift
        monday_shift = weekly_roster.weekly_shifts.find_by(day_of_week: 'monday')
        expect(monday_shift).to be_present
        expect(monday_shift.start_time.strftime('%H:%M')).to eq('09:00')
        expect(monday_shift.end_time.strftime('%H:%M')).to eq('17:00')
        expect(monday_shift.shift_type).to eq('morning')
        
        # Check Tuesday shift
        tuesday_shift = weekly_roster.weekly_shifts.find_by(day_of_week: 'tuesday')
        expect(tuesday_shift).to be_present
        expect(tuesday_shift.start_time.strftime('%H:%M')).to eq('14:00')
        expect(tuesday_shift.end_time.strftime('%H:%M')).to eq('22:00')
        expect(tuesday_shift.shift_type).to eq('afternoon')
      end

      it 'handles overnight shifts correctly' do
        service = described_class.new(base_roster: base_roster, week_start_date: week_start_date)
        weekly_roster = service.generate
        
        wednesday_shift = weekly_roster.weekly_shifts.find_by(day_of_week: 'wednesday')
        expect(wednesday_shift).to be_present
        expect(wednesday_shift.start_time.strftime('%H:%M')).to eq('18:00')
        expect(wednesday_shift.end_time.strftime('%H:%M')).to eq('02:00')
        expect(wednesday_shift.shift_type).to eq('evening')
      end
    end

    context 'with fortnightly base roster' do
      let(:fortnightly_roster) { create(:base_roster, user: user, week_type: :fortnightly) }
      let(:week_start_date) { Date.current.beginning_of_week }
      
      before do
        create(:base_shift,
                base_roster: fortnightly_roster,
                day_of_week: 'friday',
                start_time: '09:00',
                end_time: '17:00')
      end

      it 'creates weekly roster with fortnightly type' do
        service = described_class.new(base_roster: fortnightly_roster, week_start_date: week_start_date)
        weekly_roster = service.generate
        
        expect(weekly_roster.week_type).to eq('fortnightly')
      end
    end

    context 'with invalid parameters' do
      it 'raises error when base roster is nil' do
        expect {
          described_class.new(base_roster: nil, week_start_date: Date.current)
        }.to raise_error(ArgumentError, 'Base roster is required')
      end

      it 'raises error when week_start_date is nil' do
        expect {
          described_class.new(base_roster: base_roster, week_start_date: nil)
        }.to raise_error(ArgumentError, 'Week start date is required')
      end

      it 'raises error when base roster has no base shifts' do
        empty_roster = create(:base_roster, user: user)
        week_start_date = Date.current.beginning_of_week
        
        expect {
          described_class.new(base_roster: empty_roster, week_start_date: week_start_date).generate
        }.to raise_error(StandardError, 'Base roster must have shifts to generate weekly roster')
      end
    end

    context 'with existing weekly roster for same week' do
      let(:week_start_date) { Date.current.beginning_of_week }
      
      before do
        # Create an existing weekly roster for the same week
        create(:weekly_roster,
                base_roster: base_roster,
                user: user,
                week_start_date: week_start_date,
                week_end_date: week_start_date + 6.days,
                week_type: 'weekly')
      end

      it 'raises error when weekly roster already exists for week' do
        service = described_class.new(base_roster: base_roster, week_start_date: week_start_date)
        
        expect {
          service.generate
        }.to raise_error(StandardError, 'Weekly roster already exists for this week')
      end
    end
  end

  describe '#week_range' do
    let(:service) { described_class.new(base_roster: base_roster, week_start_date: Date.current.beginning_of_week) }
    
    it 'returns correct week start and end dates' do
      week_start = Date.current.beginning_of_week
      week_end = week_start + 6.days
      
      expect(service.send(:week_range)).to eq([week_start, week_end])
    end
  end
end