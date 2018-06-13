require "rails_helper"

RSpec.describe Round, :type => :model do
  let(:round) { create(:round) }
  context "Expiration" do
    it "should be closed for old rounds" do
      round.expiration_date = DateTime.now - 2.days
      expect(round).not_to be_open
    end

    it "should be open for new rounds" do
      expect(round).to be_open
    end
  end

  context "bets getter" do
    it "should return bet for each game" do
      user = create(:user)
      game1 = create(:game, round: round)
      game2 = create(:game, round: round)
      game3 = create(:game, round: round)

      bet1 = create(:bet, user: user, game: game1, answer: :tie)

      bets = round.bets(user)
      bets_games = bets.map(&:game)

      expect(bets).to include(bet1)
      expect(bets.length).to eq(3)
      expect(bets_games).to include(game2)
      expect(bets_games).to include(game3)
    end

    it "should update bets" do
      user = create(:user)
      game1 = create(:game, round: round)
      game2 = create(:game, round: round)
      game3 = create(:game, round: round)

      new_bets = {
        game1.id => Bet.answers[:tie],
        game2.id => Bet.answers[:team1],
        game3.id => Bet.answers[:team2],
      }

      expect(round.update_bets(new_bets, user)).to be
      bets = round.bets(user)
      expect(bets.length).to eq(3)
      answers = bets.map(&:answer)
      %w(tie team1 team2).each { |a| expect(answers).to include(a) }
    end

    it "shouldn't update missing bets" do
      user = create(:user)
      game1 = create(:game, round: round)
      game2 = create(:game, round: round)
      create(:game, round: round)  # game 3

      new_bets = {
        game1.id => Bet.answers[:team1],
        game2.id => Bet.answers[:team2],
      }

      expect { round.update_bets(new_bets, user) }.not_to(change { Bet.count })
      expect(round.errors).not_to be_empty
    end

    it "shouldn't update invalid bets" do
      user = create(:user)
      game1 = create(:game, round: round)
      game2 = create(:game, round: round)
      game4 = create(:game, round: create(:round))

      new_bets = {
        game1.id => Bet.answers[:team1],
        game2.id => Bet.answers[:team1],
        game4.id => Bet.answers[:tie],
      }

      expect { round.update_bets(new_bets, user) }.not_to(change { Bet.count })
      expect(round.errors).not_to be_empty
    end

    it "shouldn't update bets for closed rounds" do
      round.expiration_date = DateTime.now - 2.days
      round.save!
      user = create(:user)
      game = create(:game, round: round)

      new_bets = {
        game.id => Bet.answers[:tie],
      }

      expect { round.update_bets(new_bets, user) }.not_to(change { Bet.count })
      expect(round.errors).not_to be_empty
    end
  end

  it "should have to_s method" do
    expect(round.to_s).to eq(round.name)
  end

  context "expiration date" do
    it "should validate expiration date on create" do
      yesterday = DateTime.now - 1.days
      expect do
        create(:round, expiration_date: yesterday)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
    it "should allow expired round on edit" do
      round.expiration_date = DateTime.now - 1.days
      expect(round).to be_valid
    end
  end

  context "validations" do
    it { is_expected.to allow_values('Round 1', 'houses', 'final').for(:name) }
    it { is_expected.not_to allow_values('', nil, 'a').for(:name) }
    it { expect(round).to be_valid }
  end
end
