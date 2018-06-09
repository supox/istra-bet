require "rails_helper"

RSpec.describe Bet, :type => :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:bet) { Bet.new(user_id: user.id, game_id: game.id, answer: :team1) }

  context "Answer name" do
    it "should return '-' for no answer" do
      bet.answer = nil
      expect(bet.answer_name).to eq "-"
    end

    it "should return team's name for team" do
      bet.answer = :team1
      expect(bet.answer_name).to eq game.team1
      bet.answer = :team2
      expect(bet.answer_name).to eq game.team2
      bet.answer = :tie
      expect(bet.answer_name).to eq "Tie"
    end
  end

  context "Points" do
    it "should be non-zero for correct answer" do
      game.result = :team1
      game.save!
      bet.answer = :team1
      expect(bet.points).to eq game.bet_points
    end

    it "should be zero for wrong answer" do
      game.result = :team1
      game.save!
      bet.answer = :tie
      expect(bet.points).to eq 0
    end
  end

  context "validations" do
    it { expect(bet).to be_valid }
    it { is_expected.to allow_values(:tie, :team1, :team2).for(:answer) }
    it { is_expected.to belong_to(:game) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.not_to allow_values(nil).for(:answer) }
    it "must have valid answer" do
      expect { bet.answer = :bla }.to raise_error(ArgumentError)
    end
    it "Validate uniqueness" do
      user1 = create(:user)
      user2 = create(:user)
      game1 = create(:game)
      game2 = create(:game)
      bet11 = Bet.new(user_id: user1.id, game_id: game1.id, answer: :tie)
      bet11.save!
      bet11_2 = Bet.new(user_id: user1.id, game_id: game1.id, answer: :tie)
      expect(bet11_2).not_to be_valid

      bet21 = Bet.new(user_id: user2.id, game_id: game1.id, answer: :tie)
      expect(bet21).to be_valid
      bet12 = Bet.new(user_id: user1.id, game_id: game2.id, answer: :tie)
      expect(bet12).to be_valid

      # expect(create(:bet)).to validate_uniqueness_of(:game).scoped_to(:user)
    end
  end
end
