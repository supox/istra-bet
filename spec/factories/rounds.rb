FactoryBot.define do
  factory :round do
    tournament
    name "Round1"
    expiration_date {DateTime.now + 3.days}
  end
end

