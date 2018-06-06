require "rails_helper"

RSpec.describe Tournament, :type => :model do
  let(:tournament) { create(:tournament) }
  context "Scores" do
    it "should return empty for no rounds" do
      expect(tournament.scores).to be_empty
    end

    it "should return score by points" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)
      round1 = create(:round, tournament: tournament)
      game11 = create(:game, round: round1, bet_points: 2)
      game12 = create(:game, round: round1, bet_points: 4)
      round2 = create(:round, tournament: tournament)
      game21 = create(:game, round: round1, bet_points: 1)
      game22 = create(:game, round: round2, bet_points: 2)
      game23 = create(:game, round: round2, bet_points: 3)
      bet111 = create(:bet, user: user1, game: game11, answer: game11.result) # 2
      bet112 = create(:bet, user: user1, game: game12, answer: :team1) # 0
      bet121 = create(:bet, user: user1, game: game21, answer: game21.result) # 1
      bet122 = create(:bet, user: user1, game: game22, answer: :team1) # 0
      bet123 = create(:bet, user: user1, game: game23, answer: game23.result) # 3
      bet211 = create(:bet, user: user2, game: game11, answer: :team1) # 2
      bet212 = create(:bet, user: user2, game: game12, answer: game12.result) # 4
      bet221 = create(:bet, user: user2, game: game21, answer: :team1) # 0
      bet222 = create(:bet, user: user2, game: game22, answer: :team1) # 0
      bet223 = create(:bet, user: user2, game: game23, answer: game23.result) # 3
      bet323 = create(:bet, user: user3, game: game23, answer: game23.result) # 3

      expect(tournament.scores).to eq([[user2, 7], [user1, 6], [user3, 3]])
    end

  end

  it "should have to_s method" do
    expect(tournament.to_s).to eq(tournament.name)
  end

  context "validations" do
    it "must have description" do
      tournament.description = ""
      expect(tournament).to_not be_valid
    end

    it "must have a long enough name" do
      tournament.name = "a"
      expect(tournament).to_not be_valid
    end

    it "can be valid" do
      expect(tournament).to be_valid
    end
  end
end
