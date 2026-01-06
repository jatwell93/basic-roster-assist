class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  helper_method :format_time

  def format_time(time_obj)
    time_obj&.strftime("%I:%M %p")
  end
end
