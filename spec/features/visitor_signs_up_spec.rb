require 'spec_helper'

feature 'Visitor signs up' do
  scenario 'with valid email and password' do
    sign_up_with 'MyName', 'valid@example.com', 'password'

    expect(page).to have_content('Logout')
  end

  scenario 'with invalid email' do
    sign_up_with 'MyName', 'invalid_email', 'password'

    expect(page).to have_content('Log-in')
  end

  scenario 'with blank password' do
    sign_up_with 'MyName', 'valid@example.com', ''

    expect(page).to have_content('Log-in')
  end
end

