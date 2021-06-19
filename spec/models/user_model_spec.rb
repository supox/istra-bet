require "rails_helper"

RSpec.describe User, :type => :model do
  let(:user) { create(:user) }

  context "score" do
    it "can have zero games" do
      expect(user.score).to eq(0)
    end

    it "can have bad bets" do
      game = create(:game, result: :tie, bet_points: 3)
      create(:bet, user: user, game: game, answer: :team1)

      expect(user.score).to eq(0)
    end

    it "can have bad mc bets" do
      mc = create(:multi_choice, options: ["Team 1", "Team 2"], result: "Team 1", bet_points: 3)
      create(:multi_choice_bet, user: user, multi_choice: mc, answer: "Team 2")

      expect(user.score).to eq(0)
    end

    it "can have few bets" do
      game1 = create(:game, result: :tie, bet_points: 3)
      create(:bet, user: user, game: game1, answer: :team1)
      game2 = create(:game, result: :team1, bet_points: 5)
      create(:bet, user: user, game: game2, answer: :team1)

      multi_choice1 = create(:multi_choice, options: ["Team 1", "Team 2"], result: "Team 1", bet_points: 9)
      create(:multi_choice_bet, user: user, multi_choice: multi_choice1, answer: "Team 2")

      multi_choice2 = create(:multi_choice, options: ["Team 3", "Team 4"], result: "Team 3", bet_points: 11)
      create(:multi_choice_bet, user: user, multi_choice: multi_choice2, answer: "Team 3")

      expect(user.score).to eq(16)
    end
  end

  it "should have to_s method" do
    expect(user.to_s).to eq(user.name)
  end

  context "validations" do
    it { expect(user).to be_valid }
    it { is_expected.to allow_values("supox0@bla.com", "harry.potter@gmail.com").for(:email) }
    it { is_expected.not_to allow_values('', nil, 'a', 'my_name_is').for(:email) }

    it { is_expected.to allow_values("Ilan", "Gal Goldshtein").for(:name) }
    it { is_expected.not_to allow_values("", nil, "a" * 200, "!@#$%").for(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
