require "rails_helper"

describe RoundsController do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament) }
  let(:round) { create(:round, tournament: tournament) }
  let(:mc_round) { create(:round, tournament: tournament) }

  describe 'GET #show' do
    let(:game) { create(:game, round: round) }
    before do
      sign_in user
      game
      get :show, params: { id: round.id }
    end
    it { expect(assigns(:round)).to eq(round) }
    it "assigns bets" do
      expect(assigns(:bets)[0]).to be_a_new(Bet)
      expect(assigns(:bets)[0].game).to eq(game)
      expect(assigns(:bets)[0].user).to eq(user)
    end
    it { is_expected.to render_with_layout :application }
    it { is_expected.to render_template :show }
  end

  describe 'GET #bet' do
    let(:game) { create(:game, round: round) }

    before do
      game
      sign_in user
      get :bet, params: { id: round.id }
    end
    it { expect(assigns(:round)).to eq(round) }
    it "assigns bets" do
      expect(assigns(:bets)[0]).to be_a_new(Bet)
      expect(assigns(:bets)[0].game).to eq(game)
      expect(assigns(:bets)[0].user).to eq(user)
    end
    it { is_expected.to render_with_layout :application }
    it { is_expected.to render_template :bet }
  end

  describe 'GET #bet expired' do
    let(:round) { create(:expired_round_with_games)}

    before do
      sign_in user
      get :bet, params: { id: round.id }
    end

    it { expect(response).to redirect_to round_path(round) }
    it { expect(flash[:error]).to match "Round is closed" }
  end

  describe 'PUT #update_bet' do
    let(:game1) { create(:game, round: round) }
    let(:game2) { create(:game, round: round) }
    let(:game3) { create(:game, round: round) }
    before do
      sign_in user
    end

    context "Good bets" do
      before do
        new_bets = {
          game1.id => Bet.answers[:tie],
          game2.id => Bet.answers[:team1],
          game3.id => Bet.answers[:team2],
        }

        put :update_bet, params: { id: round.id, bets: new_bets, mc_bets: {} }
      end
      it "should update bets" do
        expect(Bet.all.each(&:answer)).to all(be)
      end
      it { expect(response).to redirect_to(round) }
    end

    context "Bad bets" do
      before do
        new_bets = {
          game1.id => Bet.answers[:tie],
        }
        game2
        game3

        put :update_bet, params: { id: round.id, bets: new_bets, mc_bets: {} }
      end
      it "should not update bets" do
        expect(Bet.all.each(&:answer)).to all(be_nil)
      end
      it { is_expected.to render_template :bet }
    end

    context "Good mcs" do
      before do
        multi_choice1 = create(:multi_choice, round: mc_round)
        multi_choice2 = create(:multi_choice, round: mc_round)
        multi_choice3 = create(:multi_choice, round: mc_round)
        new_mc_bets = {
          multi_choice1.id => multi_choice1.options[0],
          multi_choice2.id => multi_choice2.options[1],
          multi_choice3.id => multi_choice3.options[0],
        }

        put :update_bet, params: { id: mc_round.id, bets: {}, mc_bets: new_mc_bets }
      end
      it "should update bets" do
        expect(MultiChoiceBet.all.each(&:answer)).to all(be)
      end
      it { expect(response).to redirect_to(mc_round) }
    end

    context "Bad bets" do
      before do
        multi_choice1 = create(:multi_choice, round: mc_round)
        multi_choice2 = create(:multi_choice, round: mc_round)
        multi_choice3 = create(:multi_choice, round: mc_round)

        new_mc_bets = {
          multi_choice1.id => multi_choice1.options[0],
        }

        put :update_bet, params: { id: mc_round.id, bets: {}, mc_bets: new_mc_bets }
      end
      it "should not update bets" do
        expect(MultiChoiceBet.all.each(&:answer)).to all(be_nil)
      end
      it { is_expected.to render_template :bet }
    end

  end

  describe 'GET #new' do
    context "not admin" do
      before do
        sign_in user
        get :new, params: { tournament_id: tournament.id }
      end
      it { expect(response).to have_http_status 401 }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        get :new, params: { tournament_id: tournament.id }
      end
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :new }
      it { expect(assigns(:round)).to be_a_new(Round) }
    end
  end

  describe 'GET #edit' do
    context "not admin" do
      before do
        sign_in user
        get :edit, params: { id: round.id }
      end
      it { expect(response).to have_http_status 401 }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        get :edit, params: { id: round.id }
      end

      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :edit }
      it { expect(assigns(:round)).to eq(round) }
    end
  end

  describe 'POST #create' do
    let(:round_params) { attributes_for(:round_with_games) }
    context "not admin" do
      before do
        sign_in user
      end
      it {
        expect do
          post :create, params: { tournament_id: tournament.id, round: round_params }
        end.not_to(change { Round.count })
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
      end
      it {
        expect do
          post :create, params: { tournament_id: tournament.id, round: round_params }
        end.to change { Round.count }.by(1)
      }
    end
  end

  describe 'PUT #update' do
    let(:attr) { attributes_for(:round_with_games, name: "NEW NAME") }
    context "not admin" do
      before do
        sign_in user
        put :update, params: { id: round.id, round: attr }
        tournament.reload
      end
      it {
        expect(round.name).not_to eq("NEW NAME")
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        put :update, params: { id: round.id, round: attr }
        round.reload
      end
      it { expect(round.name).to eq("NEW NAME") }
      it { expect(response).to redirect_to(@round) }
    end
  end

  describe 'DELETE #destroy' do
    context "not admin" do
      before do
        sign_in user
      end
      it {
        round
        expect { delete :destroy, params: { id: round.id } }.not_to(change { Round.count })
      }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
      end
      it {
        round
        expect { delete :destroy, params: { id: round.id } }.to change { Round.count }.by(-1)
      }
      it "redirect to index" do
        delete :destroy, params: { id: round.id }
        expect(response).to redirect_to tournament_path(tournament)
      end
    end
  end

  ## MAILS ##
  describe 'GET #mail' do
    context "not admin" do
      before do
        sign_in user
        get :mail, params: { id: round.id }
      end
      it { expect(response).to have_http_status 401 }
    end

    context "admin" do
      let(:user) { create(:admin) }
      before do
        sign_in user
        get :mail, params: { id: round.id }
      end

      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :mail }
      it { expect(assigns(:round)).to eq(round) }
    end
  end

  describe 'PUT #send_mail' do
    context "not admin" do
      before do
        sign_in user
      end
      it {
        expect do
          put :send_mail, params: { id: round.id, mail: { subject: "sub", text: "text" } }
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
            id: round.id,
            round_mail: { subject: "this is the subject", body: "this is the body" },
          }
        end.to(change { ActionMailer::Base.deliveries.count }.by(4))
      }
      it "shouldn't send to unsubscribed" do
        expect do
          u = User.first
          u.subscription = false
          u.save!
          put :send_mail, params: {
            id: round.id,
            round_mail: { subject: "this is the subject", body: "this is the body" },
          }
        end.to(change { ActionMailer::Base.deliveries.count }.by(3))
      end
      it "shouldn't update for short subject" do
        expect do
          put :send_mail, params: { id: round.id, round_mail: { subject: "sub", body: "ttt" } }
        end.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end
  end
end
