class RoundsMailer < ApplicationMailer
  def notify_round(text, subject, round, user)
    @text = text
    @round = round
    @unsubscribe = Rails.application.message_verifier(:unsubscribe).generate(user.id)
    mail to: user.email, subject: subject
  end
end
