require "rails_helper"

RSpec.describe MultiChoice, :type => :model do
  let(:mc) { create(:multi_choice) }

  context "validations" do
    it { expect(mc).to be_valid }

    it { is_expected.to allow_values("Round 1", "House A", "Bla").for(:description) }
    it { is_expected.not_to allow_values("", nil, "a" * 200).for(:description) }

    it { is_expected.to allow_values(1, 2, 16).for(:bet_points) }
    it { is_expected.not_to allow_values("", nil, 0, -10).for(:bet_points) }

    it { is_expected.to belong_to(:round) }

    it { is_expected.to allow_values(["Israel", "Germany"], ["Spain", "Denmark", "USA"]).for(:options) }
    it { is_expected.not_to allow_values(nil, ['a'], ['a', "Denmark"], Array.new(2000) {|i| "team#{i+1}" }).for(:options) }

    it "shouldn't have unique values in options" do
      mc.options = ["Argentina", "Germany", "Argentina", "Israel"]
      expect(mc).not_to be_valid
    end

    it "should have result one of the options" do
      mc.options = ["Team 1", "Team 2"]
      mc.result = "Team 1"

      expect(mc).to be_valid
    end

    it "shouldn't have result not one of the options" do
      mc.options = ["Team 1", "Team 2"]
      mc.result = "Team 3"

      expect(mc).not_to be_valid
    end
  end
end

