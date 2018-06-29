class TournamentsMailer < ApplicationMailer
  def notify_tournament(text, subject, tournament, users)
    @text = text
    @tournament = tournament

    mail bcc: users.map(&:email), subject: subject
  end
end
