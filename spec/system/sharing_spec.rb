require 'rails_helper'

RSpec.describe 'Sharing', type: :system do
  include Devise::Test::IntegrationHelpers
  let(:owner) { create(:user) }
  let(:collaborator) { create(:user) }
  let!(:password_record) { create(:password_record, user: owner, title: 'Test Password') }

  describe 'Sharing all password records' do
    before do
      sign_in owner
      visit password_records_path
    end

    it 'allows sharing with other users' do
      fill_in 'email', with: collaborator.email
      click_button 'Share Access'

      expect(page).to have_content("Access shared with #{collaborator.email}")
    end

    it 'allows revoking access' do
      fill_in 'email', with: collaborator.email
      click_button 'Share Access'

      find('button', text: /Manage Access ▼/).click

      within('.dropdown-content') do
        click_button 'Revoke All Access'
      end

      accept_confirm

      expect(page).to have_content('Access removed')
      expect(page).not_to have_content(collaborator.email)
    end

    it 'shows error when sharing with invalid email' do
      fill_in 'email', with: 'invalid@email'
      click_button 'Share Access'

      expect(page).to have_content('User not found')
    end
  end

  describe 'Accessing shared records' do
    before do
      create(:shared_password_record, owner: owner, collaborator: collaborator, password_record: password_record)
      sign_in collaborator
      visit password_records_path
    end

    it 'shows shared records' do
      expect(page).to have_content('Shared passwords')
      expect(page).to have_content(password_record.title)
    end

    it 'prevents editing shared records' do
      visit password_record_path(password_record)

      expect(page).not_to have_link('Edit')
      expect(page).not_to have_link('Delete')
    end
  end
end
