RSpec.describe RoundsMailer, type: :mailer do
  describe 'new_round' do
    let(:users) { create_list(:user, 3) }
    let(:round) { create(:round) }
    let(:text) { "Please bet!" }
    let(:subject) { "New round is available!" }
    let(:mail) { described_class.notify_round(text, subject, round, users).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq(subject)
    end

    it 'renders the receiver email' do
      expect(mail.bcc).to eq(users.collect(&:email))
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['no-reply@betibam.herokuapp.com'])
    end

    it 'contains round url' do
      expect(mail.body.encoded).to match(round_url(round))
    end

    it 'contains text' do
      expect(mail.body.encoded).to match(text)
    end
  end
end
