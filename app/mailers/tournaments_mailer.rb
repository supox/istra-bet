class TournamentsMailer < ApplicationMailer
  def notify_tournament(text, subject, tournament, user)
    @text = text
    @tournament = tournament
    @unsubscribe = Rails.application.message_verifier(:unsubscribe).generate(user.id)

    mail to: user.email, subject: subject
  end
end

