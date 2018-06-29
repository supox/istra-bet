RSpec.describe TournamentsMailer, type: :mailer do
  describe 'tournament_mailer' do
    let(:users) { create_list(:user, 3) }
    let(:tournament) { create(:tournament) }
    let(:text) { "Please bet!" }
    let(:subject) { "My nice subject" }
    let(:mail) { described_class.notify_tournament(text, subject, tournament, users).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq(subject)
    end

    it 'renders the receiver email' do
      expect(mail.bcc).to eq(users.collect(&:email))
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['no-reply@betibam.herokuapp.com'])
    end

    it 'contains tournament url' do
      expect(mail.body.encoded).to match(tournament_url(tournament))
    end

    it 'contains text' do
      expect(mail.body.encoded).to match(text)
    end
  end
end
