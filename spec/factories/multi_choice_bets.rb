FactoryBot.define do
  factory :multi_choice_bet do
    multi_choice
    user
    answer { "Team 1" }
  end
end
