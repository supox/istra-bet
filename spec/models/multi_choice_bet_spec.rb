require 'rails_helper'

RSpec.describe MultiChoiceBet, type: :model do
  let(:user) { create(:user) }
  let(:multi_choice) { create(:multi_choice, options: ["Team 1", "Team 2", "Team 3"], result: "Team 1") }
  let(:mc) { MultiChoiceBet.new(user_id: user.id, multi_choice_id: multi_choice.id, answer: "Team 1") }

  context "Answer name" do
    it "should return '-' for no answer" do
      mc.answer = nil
      expect(mc.answer_name).to eq "-"
    end

    it "should return team's name" do
      mc.answer = "Team 1"
      expect(mc.answer_name).to eq "Team 1"
    end
  end

  context "Points" do
    it "should be non-zero for correct answer" do
      multi_choice.result = "Team 1"
      multi_choice.save!
      mc.answer = "Team 1"
      expect(mc.points).to eq multi_choice.bet_points
    end

    it "should be zero for wrong answer" do
      multi_choice.result = "Team 2"
      multi_choice.save!
      mc.answer = "Team 1"
      expect(mc.points).to eq 0
    end
  end

  context "validations" do
    it { expect(mc).to be_valid }
    it { expect(mc).to allow_values("Team 1", "Team 2").for(:answer) }
    it { expect(mc).to belong_to(:multi_choice) }
    it { expect(mc).to belong_to(:user) }
    it { expect(mc).not_to allow_values(nil, "Bla", "WOW", "team").for(:answer) }
    it "Validate uniqueness" do
      user1 = create(:user)
      user2 = create(:user)
      multi_choice1 = create(:multi_choice)
      multi_choice2 = create(:multi_choice)
      mc11 = MultiChoiceBet.new(user_id: user1.id, multi_choice_id: multi_choice1.id, answer: multi_choice1.options[0])
      mc11.save!
      mc11_2 = MultiChoiceBet.new(user_id: user1.id, multi_choice_id: multi_choice1.id, answer: multi_choice2.options[1])
      expect(mc11_2).not_to be_valid

      mc21 = MultiChoiceBet.new(user_id: user2.id, multi_choice_id: multi_choice1.id, answer: multi_choice1.options[0])
      expect(mc21).to be_valid
      mc12 = MultiChoiceBet.new(user_id: user1.id, multi_choice_id: multi_choice2.id, answer: multi_choice1.options[1])
      expect(mc12).to be_valid
    end
  end
end
