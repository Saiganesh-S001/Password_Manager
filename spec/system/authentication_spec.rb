require 'rails_helper'

RSpec.describe 'Authentication', type: :system do
  let!(:user) { create(:user, email: "sai@gmail.com", password: "password123", password_confirmation: "password123") }

  describe 'Sign up' do
    it 'allows new users to register' do
      visit new_user_registration_path
      fill_in 'Email', with: 'newuser@gmail.com'
      fill_in 'Display name', with: 'New User'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      click_button 'Sign up'

      expect(page).to have_content('Welcome! You have signed up successfully')
    end
  end

  describe 'Sign in' do
    it 'allows users to sign in with valid credentials' do
      visit new_user_session_path
      fill_in 'Email', with: 'sai@gmail.com'
      fill_in 'Password', with: 'password123', exact: true
      click_button 'Log in'

      expect(page).to have_content('Signed in successfully')
      expect(page).to have_current_path(root_path)
    end

    it 'shows error with invalid credentials' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'wrong_password'
      click_button 'Log in'

      expect(page).to have_content('Invalid Email or password')
    end
  end
end
