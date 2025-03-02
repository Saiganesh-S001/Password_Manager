require 'rails_helper'

RSpec.describe SharedAccess, type: :model do
  it { is_expected.to belong_to(:owner).class_name('User') }
  it { is_expected.to belong_to(:collaborator).class_name('User') }

  let(:owner) { create(:user) }
  let(:collaborator) { create(:user) }
  let(:another_collaborator) { create(:user) }
  let(:shared_access) { create(:shared_access, owner: owner, collaborator: collaborator) }

  it "allows user to share passwords" do
    expect(shared_access).to be_valid
    expect(shared_access.owner).to eq(owner)
    expect(shared_access.collaborator).to eq(collaborator)
  end

  context "Sharing Passwords" do
    it "allows user to share passwords with more than one user" do
      create(:shared_access, owner: owner, collaborator: another_collaborator)
      expect(shared_access.valid?).to eq(true)
      expect(SharedAccess.where(owner: owner).count).to eq(2)
    end
  end
end
