# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class RoundsMailerPreview < ActionMailer::Preview
  def notify_round_preview
    RoundsMailer.notify_round(text: "hello guys\nlets party!!",
                              subject: "test subject",
                              round: Round.first,
                              users: User.all)
  end
end
