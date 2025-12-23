class ClockInsController < ApplicationController
  def new
    # Show PIN entry form
  end

  def create
    pin = params[:pin]

    if pin.blank?
      flash.now[:alert] = "PIN is required"
      render :new, status: :unprocessable_entity
      return
    end

    # Find user by PIN (assuming PIN is unique)
    user = User.find_by_pin(pin)

    if user.nil?
      flash.now[:alert] = "Invalid PIN"
      render :new, status: :unprocessable_entity
      return
    end

    # Determine if user is currently clocked in
    currently_clocked_in = user.time_entries.where(clock_out: nil).exists?

    # Use ClockInService to handle the clock in/out logic
    service = ClockInService.new(user: user, pin: pin)

    begin
      if currently_clocked_in
        # Clock out
        time_entry = service.clock_out
        flash[:notice] = "Successfully clocked out. Shift duration: #{time_entry.hours_worked.round(2)} hours"
        redirect_to new_clock_in_path
      else
        # Clock in
        service.clock_in
        flash[:notice] = "Successfully clocked in at #{Time.current.strftime('%H:%M')}"
        redirect_to new_clock_in_path
      end
    rescue ClockInService::InvalidPinError
      flash.now[:alert] = "Invalid PIN"
      render :new, status: :unprocessable_entity
    rescue ClockInService::AlreadyClockedInError
      flash.now[:alert] = "You are already clocked in"
      render :new, status: :unprocessable_entity
    rescue ClockInService::NotClockedInError
      flash.now[:alert] = "You are not currently clocked in"
      render :new, status: :unprocessable_entity
    rescue ClockInService::ShiftTooLongError
      flash.now[:alert] = "Cannot clock out - shift exceeds maximum duration"
      render :new, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("Clock in/out error: #{e.message}")
      flash.now[:alert] = "An error occurred. Please try again."
      render :new, status: :internal_server_error
    end
  end
end
