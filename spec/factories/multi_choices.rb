FactoryBot.define do
  factory :multi_choice do
    round
    sequence(:description) { |n| "Description #{n}" }
    options { ["Austria", "Brazil", "Denmark"] }
    bet_points { 2 }
    result { "Brazil" }
  end
end

