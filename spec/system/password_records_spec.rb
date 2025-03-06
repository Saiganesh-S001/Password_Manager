require 'rails_helper'

RSpec.describe 'Password Records', type: :system do
  include Devise::Test::IntegrationHelpers
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'Creating password records' do
    it 'allows creating new password records' do
      visit password_records_path
      click_link 'New'

      fill_in 'password_record_title', with: 'Gmail Account'
      fill_in 'password_record_username', with: 'test@gmail.com'
      fill_in 'password_record_password', with: 'secure_password'
      fill_in 'password_record_url', with: 'https://gmail.com'

      click_button 'Create Password record'

      expect(page).to have_content('Password record was successfully created')
      expect(page).to have_content('Gmail Account')
    end

    it 'shows validation errors' do
      visit new_password_record_path
      click_button 'Create Password record'

      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content("Username can't be blank")
      expect(page).to have_content("Url can't be blank")
    end
  end

  describe 'Managing password records' do
    let!(:password_record) { create(:password_record, user: user) }

    it 'allows viewing password records', js: true do
      visit password_records_path
      click_link password_record.title

      if page.has_content?('Enter Security Key')
        fill_in 'password', with: user.password
        click_button 'Verify'
        expect(page).not_to have_content('Enter Security Key') # Wait for verification
      end

      click_link password_record.title # remove this (redirect to that password record on verification)
      expect(page).to have_content(password_record.username, wait: 5)
      expect(page).to have_content(password_record.url, wait: 5)
    end

    it 'allows editing password records' do
      visit password_record_path(password_record)

      if page.has_content?('Enter Security Key')
        fill_in 'password', with: user.password
        click_button 'Verify'
        expect(page).not_to have_content('Enter Security Key') # Wait for verification
      end

      visit password_record_path(password_record)
      click_link 'Edit'

      fill_in 'password_record_title', with: 'Updated Title'
      click_button 'Update Password record'

      expect(page).to have_content('Password record was successfully updated')
      expect(page).to have_content('Updated Title')
    end

    it 'allows deleting password records' do
      visit password_record_path(password_record)

      if page.has_content?('Enter Security Key')
        fill_in 'password', with: user.password
        click_button 'Verify'
        expect(page).not_to have_content('Enter Security Key') # Wait for verification
      end

      visit password_record_path(password_record)

      accept_confirm do
        click_button 'Delete'
      end

      # check path
      expect(page).to have_current_path(password_records_path)

      expect(page).to have_content('Password record was successfully destroyed')
      expect(page).not_to have_content(password_record.title)
    end
  end

  describe 'Searching password records' do
    let!(:gmail) { create(:password_record, user: user, title: 'Gmail', username: 'gmail_user') }
    let!(:github) { create(:password_record, user: user, title: 'GitHub', username: 'github_user') }

    it 'allows searching by title' do
      visit password_records_path
      fill_in 'search_by_title', with: 'Gmail'
      click_button 'Search'

      expect(page).to have_selector('a', text: 'Gmail')
      expect(page).not_to have_selector('a', text: 'GitHub')
    end

    it 'allows searching by username' do
      visit password_records_path
      fill_in 'search_by_username', with: 'gmail_user'
      click_button 'Search'

      expect(page).to have_selector('a', text: 'Gmail')
      expect(page).not_to have_selector('a', text: 'GitHub')
    end
  end
end
