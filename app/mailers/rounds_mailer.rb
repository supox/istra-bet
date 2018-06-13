class RoundsMailer < ApplicationMailer
  def notify_round(text, subject, round, users)
    @text = text
    @round = round

    mail bcc: users.map(&:email), subject: subject
  end
end
