require "rails_helper"

RSpec.describe Bet, :type => :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:bet) { Bet.new({user_id: user.id, game_id: game.id, answer: :team1}) }

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
    it "must have user" do
      bet.user_id = nil
      expect(bet).to_not be_valid
    end

    it "must have game" do
      bet.game_id = nil
      expect(bet).to_not be_valid
    end

    it "must have valid answer" do
      expect {bet.answer = :bla}.to raise_error(ArgumentError)
    end

    it "can be valid" do
      expect(bet).to be_valid
    end
  end
end
