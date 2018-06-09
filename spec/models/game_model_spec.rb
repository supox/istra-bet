require "rails_helper"

RSpec.describe Game, :type => :model do
  let(:game) { create(:game) }

  context "validations" do
    it { expect(game).to be_valid }
    it { is_expected.to allow_values("Israel", "Germany", "Spain").for(:team1) }
    it { is_expected.to allow_values("Israel", "Germany", "Spain").for(:team2) }
    it { is_expected.not_to allow_values('', nil, 'a').for(:team1) }
    it { is_expected.not_to allow_values('', nil, 'a').for(:team2) }
    it { is_expected.not_to allow_values('', nil, 'a').for(:team2) }
    it { is_expected.to belong_to(:round) }
    it { is_expected.to allow_values("Round 1", "House A", "Bla").for(:description) }
    it { is_expected.not_to allow_values("", nil, "a" * 200).for(:description) }

    it { is_expected.to allow_values(1, 2, 16).for(:bet_points) }
    it { is_expected.not_to allow_values("", nil, 0, -10).for(:bet_points) }

    it "shouldn't have the same team" do
      game.team1 = "Argentina"
      game.team2 = "Argentina"
      expect(game).not_to be_valid
    end
  end
end
