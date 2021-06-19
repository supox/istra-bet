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
      create(:game, round: round) # game 3

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


  context "multi_choice" do
    it "should return multi_choice_bet for each multi_choice" do
      user = create(:user)
      mc1 = create(:multi_choice, round: round)
      mc2 = create(:multi_choice, round: round)
      mc3 = create(:multi_choice, round: round)

      bet1 = create(:multi_choice_bet, user: user, multi_choice: mc1, answer: mc1.options[1])

      mc_bets = round.mc_bets(user)
      bets_multi_choices = mc_bets.map(&:multi_choice)

      expect(mc_bets).to include(bet1)
      expect(mc_bets.length).to eq(3)
      expect(bets_multi_choices).to include(mc2)
      expect(bets_multi_choices).to include(mc3)
    end

    it "should update multi_choice_multi_choice_bets" do
      user = create(:user)
      multi_choice1 = create(:multi_choice, round: round)
      multi_choice2 = create(:multi_choice, round: round)
      multi_choice3 = create(:multi_choice, round: round)

      new_multi_choice_bets = {
        multi_choice1.id => multi_choice1.options[0],
        multi_choice2.id => multi_choice2.options[0],
        multi_choice3.id => multi_choice3.options[0],
      }

      expect(round.update_multi_choice_bets(new_multi_choice_bets, user)).to be
      multi_choice_bets = round.mc_bets(user)
      expect(multi_choice_bets.length).to eq(3)
      answers = multi_choice_bets.map(&:answer)
      [multi_choice1.options[0], multi_choice2.options[0], multi_choice3.options[0]].each { |a| expect(answers).to include(a) }
    end

    it "shouldn't update missing multi_choice_bets" do
      user = create(:user)
      multi_choice1 = create(:multi_choice, round: round)
      multi_choice2 = create(:multi_choice, round: round)
      create(:multi_choice, round: round) # multi_choice 3

      new_multi_choice_bets = {
        multi_choice1.id => multi_choice1.options[0],
        multi_choice2.id => multi_choice2.options[1],
      }

      expect { round.update_multi_choice_bets(new_multi_choice_bets, user) }.not_to(change { MultiChoiceBet.count })
      expect(round.errors).not_to be_empty
    end

    it "shouldn't update multi_choice_bets of another rounds" do
      user = create(:user)
      multi_choice1 = create(:multi_choice, round: round)
      multi_choice2 = create(:multi_choice, round: round)
      multi_choice4 = create(:multi_choice, round: create(:round))

      new_multi_choice_bets = {
        multi_choice1.id => multi_choice1.options[0],
        multi_choice2.id => multi_choice2.options[1],
        multi_choice4.id => multi_choice4.options[1],
      }

      expect { round.update_multi_choice_bets(new_multi_choice_bets, user) }.not_to(change { MultiChoiceBet.count })
      expect(round.errors).not_to be_empty
    end

    it "shouldn't update multi_choice_bets for closed rounds" do
      round.expiration_date = DateTime.now - 2.days
      round.save!
      user = create(:user)
      multi_choice = create(:multi_choice, round: round)

      new_multi_choice_bets = {
        multi_choice.id => multi_choice.options[0],
      }

      expect { round.update_multi_choice_bets(new_multi_choice_bets, user) }.not_to(change { MultiChoiceBet.count })
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
