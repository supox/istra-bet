FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "israel#{n}" }
    sequence(:email) { |n| "israel#{n}@mail.com" }
    password "12345678"
    sequence(:reset_password_token) { |n| "reset_#{n}" }
    reset_password_sent_at nil
    remember_created_at nil
    sign_in_count 1
    current_sign_in_at { DateTime.now }
    last_sign_in_at { DateTime.now }
    current_sign_in_ip "8.8.8.8"
    last_sign_in_ip "0.0.0.0"
    sequence(:confirmation_token) { |n| "confirm_#{n}" }
    confirmed_at { DateTime.now }
    confirmation_sent_at { DateTime.now }
    sequence(:unconfirmed_email) { |n| "israel#{n}@mail.com" }
    admin false

    factory :admin do
      admin true
    end
  end
end
