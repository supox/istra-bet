FactoryBot.define do
  factory :bet do
    game
    user
    answer { "tie" }
  end
end
