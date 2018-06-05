FactoryBot.define do
  factory :user do
    email "ilan@mail.com"
    password "12345678"
    reset_password_token ""
    reset_password_sent_at nil
    remember_created_at nil
    sign_in_count 1
    current_sign_in_at { DateTime.now }
    last_sign_in_at { DateTime.now }
    current_sign_in_ip "8.8.8.8"
    last_sign_in_ip "0.0.0.0"
    confirmation_token "123123123"
    confirmed_at { DateTime.now }
    confirmation_sent_at { DateTime.now }
    unconfirmed_email "ilan@mail.com"
    admin false
  end

  factory :admin, class: User do
    admin true
  end
end

