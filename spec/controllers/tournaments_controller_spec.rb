require "rails_helper"

describe TournamentsController do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        sign_in user
        get :index
      end
      it { is_expected.to respond_with :ok }
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :index }
      it {
        create_list(:tournament, 2)
        expect(assigns(:tournaments)).to eq(Tournament.all)
      }
    end

    context 'when user is logged out' do
      before do
        get :index
      end
      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  describe 'GET #show' do
    before do
      sign_in user
      get :show, params: { id: tournament.id }
    end
    it { expect(assigns(:tournament)).to eq(tournament) }
    it { is_expected.to render_with_layout :application }
    it { is_expected.to render_template :show }
  end

  describe 'GET #new' do
    context "not admin" do
      before do
        sign_in user
        get :new
      end
      it { expect(response).to have_http_status 401 }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        get :new
      end
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :new }
      it { expect(assigns(:tournament)).to be_a_new(Tournament) }
    end
  end

  describe 'GET #edit' do
    context "not admin" do
      before do
        sign_in user
        get :edit, params: { id: tournament.id }
      end
      it { expect(response).to have_http_status 401 }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        get :edit, params: { id: tournament.id }
      end

      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :edit }
      it { expect(assigns(:tournament)).to eq(tournament) }
    end
  end

  describe 'POST #create' do
    context "not admin" do
      before do
        sign_in user
      end
      it {
        tournament_params = attributes_for(:tournament)
        expect do
          post :create, params: { tournament: tournament_params }
        end.not_to(change { Tournament.count })
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
      end
      it {
        tournament_params = attributes_for(:tournament)
        expect do
          post :create, params: { tournament: tournament_params }
        end.to change { Tournament.count }.by(1)
      }
    end
  end

  describe 'PUT #update' do
    let(:attr) { attributes_for(:tournament, description: "NEW DESC") }
    context "not admin" do
      before do
        sign_in user
        put :update, params: { id: tournament.id, tournament: attr }
        tournament.reload
      end
      it {
        expect(tournament.description).not_to eq("NEW DESC")
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        put :update, params: { id: tournament.id, tournament: attr }
        tournament.reload
      end
      it { expect(tournament.description).to eq("NEW DESC") }
      it { expect(response).to redirect_to(@tournament) }
    end
  end

  describe 'DELETE #destroy' do
    context "not admin" do
      before do
        sign_in user
      end
      it {
        tournament
        expect do
          delete :destroy, params: { id: tournament.id }
        end.not_to(change { Tournament.count })
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
      end
      it {
        tournament
        expect do
          delete :destroy, params: { id: tournament.id }
        end.to change { Tournament.count }.by(-1)
      }
      it "redirect to index" do
        delete :destroy, params: { id: tournament.id }
        expect(response).to redirect_to tournaments_path
      end
    end
  end

  ## MAILS ##
  describe 'GET #mail' do
    context "not admin" do
      before do
        sign_in user
        get :mail, params: { id: tournament.id }
      end
      it { expect(response).to have_http_status 401 }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        get :mail, params: { id: tournament.id }
      end

      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :mail }
      it { expect(assigns(:tournament)).to eq(tournament) }
    end
  end

  describe 'PUT #send_mail' do
    context "not admin" do
      before do
        sign_in user
      end
      it {
        expect do
          put :send_mail, params: { id: tournament.id, mail: { subject: "sub", text: "text" } }
        end.not_to(change { ActionMailer::Base.deliveries.count })
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        create_list(:user, 3)
      end
      it {
        expect do
          put :send_mail, params: {
            id: tournament.id,
            tournament_mail: { subject: "this is the subject", body: "this is the body" },
          }
        end.to(change { ActionMailer::Base.deliveries.count }.by(4))
      }
      it "shouldn't send to unsubscribed" do
        expect do
          u = User.last
          u.subscription = false
          u.save!
          put :send_mail, params: {
            id: tournament.id,
            tournament_mail: { subject: "this is the subject", body: "this is the body" },
          }
        end.to(change { ActionMailer::Base.deliveries.count }.by(3))
      end
      it "shouldn't update for short subject" do
        expect do
          put :send_mail, params: { id: tournament.id, tournament_mail: { subject: "sub", body: "ttt" } }
        end.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end
  end
end
