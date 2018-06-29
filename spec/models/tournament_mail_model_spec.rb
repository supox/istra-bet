require "rails_helper"

RSpec.describe TournamentMail, type: :model do
  context "validations" do
    it { is_expected.to allow_values("New tournament available", "Please bet!").for(:subject) }
    it { is_expected.not_to allow_values("", nil, "a" * 200, "!@").for(:subject) }

    it { is_expected.to allow_values("New tournament available", "Please bet!").for(:body) }
    it { is_expected.not_to allow_values("", nil, "a" * 2000, "!@#$%").for(:body) }
  end
end
