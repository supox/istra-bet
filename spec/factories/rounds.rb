FactoryBot.define do
  factory :round do
    tournament
    sequence(:name) { |n| "Round #{n}" }
    expiration_date { DateTime.now + 3.days }
    factory :round_with_games do
      transient do
        games_count 5
      end
      after(:create) do |round, evaluator|
        create_list(:game, evaluator.games_count, round: round)
      end
    end
  end
end
