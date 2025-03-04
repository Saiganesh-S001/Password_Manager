require 'rails_helper'

RSpec.describe 'Sharing', type: :system do
  include Devise::Test::IntegrationHelpers
  let(:owner) { create(:user) }
  let(:collaborator) { create(:user) }
  let!(:password_record) { create(:password_record, user: owner) }

  describe 'Sharing all password records' do
    before do
      sign_in owner
    end

    it 'allows sharing all passwords with other users' do
      visit password_records_path
      fill_in 'email', with: collaborator.email

      select 'Share All', from: 'password_record_id'

      click_button 'Share Access'

      expect(page).to have_content("Access shared with #{collaborator.email}")
    end

    it 'prevents sharing with invalid users' do
      visit password_records_path
      fill_in 'email', with: 'invalid_email@example.com'
      click_button 'Share Access'

      expect(page).to have_content('Invalid user')
    end

    it 'allows revoking access', js: true do
      create(:shared_access, owner: owner, collaborator: collaborator)

      visit password_records_path
      click_button 'Manage Access'

      accept_confirm do
        click_button "Revoke All Access"
      end

      expect(page).to have_content('Access removed')
    end
  end

  describe 'Accessing shared records' do
    before do
      create(:shared_access, owner: owner, collaborator: collaborator)
      sign_in collaborator
    end

    it 'shows shared records' do
      visit password_records_path
      expect(page).to have_selector('a', text: password_record.title)
    end

    it 'prevents editing shared records' do
      visit password_record_path(password_record)

      expect(page).not_to have_link('Edit')
      expect(page).not_to have_link('Delete')
    end
  end
end
