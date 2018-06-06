FactoryBot.define do
  factory :game do
    round
    description "game_desc"
    team1 "Brazil"
    team2 "Argentina"
    start_time { DateTime.now }
    bet_points 2
    result 3
  end
end
