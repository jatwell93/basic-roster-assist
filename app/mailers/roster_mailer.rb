class RosterMailer < ApplicationMailer
  def roster_published(roster)
    @roster = roster
    @user = roster.user

    mail(
      to: @user.email,
      subject: "New Roster Published - #{roster.name}"
    )
  end
end
