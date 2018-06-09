module Features
  module SessionHelpers
    def sign_up_with(name, email, password)
      visit new_user_registration_path
      fill_in 'Name', with: name
      fill_in 'Email', with: email
      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: password
      click_button 'Sign Up'
    end

    def sign_in(user)
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'user_password', with: user.password
      click_button 'Log in'
    end
  end
end
