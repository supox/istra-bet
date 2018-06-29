# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class TournamentsMailerPreview < ActionMailer::Preview
  def notify_tournament_preview
    TournamentsMailer.notify_tournament("hello guys\nlets party!!",
    "test subject",
    Tournament.first,
    User.all)
  end
end

