# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class RoundsMailerPreview < ActionMailer::Preview
  def notify_round_preview
    RoundsMailer.notify_round("hello guys\nlets party!!",
                              "test subject",
                              Round.first,
                              User.all)
  end
end
