require "rails_helper"

describe PagesController do
  let(:user) { create(:user) }

  describe 'GET #home' do
    context 'when user is logged in' do
      before do
        sign_in user
        create_list(:tournament, 2)
        get :home
      end
      it { is_expected.to respond_with :ok }
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :home }
      it { expect(assigns(:tournaments)).to eq(Tournament.all) }
      it { expect(assigns(:users)).to eq(nil) }
    end
    context "when user is admin" do
      let (:user) {create(:admin)}
      before do
        sign_in user
        create_list(:tournament, 2)
        get :home
      end
      it { is_expected.to respond_with :ok }
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :home }
      it { expect(assigns(:tournaments)).to eq(Tournament.all) }
      it { expect(assigns(:users)).to eq(User.confirmed.all) }
    end

    context 'when user is logged out' do
      before do
        get :home
      end
      it { is_expected.to redirect_to new_user_session_path }
    end
  end
end