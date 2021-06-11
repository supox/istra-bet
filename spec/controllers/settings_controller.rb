require "rails_helper"

describe SettingsController do
  let(:user) { create(:user) }
  let(:unsubscribe) { Rails.application.message_verifier(:unsubscribe).generate(user.id) }

  describe 'GET #unsubscribe' do
    before do
      # sign_in user
      get :unsubscribe, id: unsubscribe
    end
    it { is_expected.to render_with_layout :application }
    it { is_expected.to render_template :unsubscribe }
  end

  describe 'GET #unsubscribe bad ID' do
    before do
      get :unsubscribe, id: :BAD_ID
    end
    it { is_expected.to render_with_layout :application }
    it { is_expected.not_to render_template :unsubscribe }
  end

  describe 'PATCH #update' do
    before do
      patch :update, params: { id: unsubscribe, subscription: false }
    end
    it { expect(user.subscription).to eq(false) }
  end

  describe 'PATCH #update re-enable' do
    before do
      patch :update, params: { id: unsubscribe, subscription: true }
    end
    it { expect(user.subscription).to eq(true) }
  end

  describe 'PATCH #update BAD' do
    before do
      patch :update, params: { id: :BAD_ID, subscription: false }
    end
    it { is_expected.to render_with_layout :application }
    it { expect(user.subscription).to eq(true) }
  end

end
