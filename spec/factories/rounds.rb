FactoryBot.define do
  factory :round do
    tournament
    sequence(:name) {|n| "Round #{n}" }
    expiration_date {DateTime.now + 3.days}
  end
end

