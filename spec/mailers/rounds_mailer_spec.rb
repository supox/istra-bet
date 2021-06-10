RSpec.describe RoundsMailer, type: :mailer do
  describe 'new_round' do
    let(:user) { create(:user) }
    let(:round) { create(:round) }
    let(:text) { "Please bet!" }
    let(:subject) { "New round is available!" }
    let(:mail) { described_class.notify_round(text, subject, round, user).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq(subject)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.reply_to).to eq(['no-reply@betibam.herokuapp.com'])
    end

    it 'contains round url' do
      expect(mail.body.encoded).to match(round_url(round))
    end

    it 'contains text' do
      expect(mail.body.encoded).to match(text)
    end

    it 'contains unsubscribe link' do
      unsubscribe = Rails.application.message_verifier(:unsubscribe).generate(user.id)
      expect(mail.body.encoded).to include(settings_unsubscribe_url(id: unsubscribe))
    end
  end
end

