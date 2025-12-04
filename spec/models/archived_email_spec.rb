require 'rails_helper'

RSpec.describe ArchivedEmail, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:original_file_name) }

    it 'has a attached file' do
      archived_email = build(:archived_email)
      expect(archived_email.eml_file).to be_attached
    end

    it 'validates presence of eml_file attachment' do
      no_file = build(:archived_email, eml_file: nil)
      expect(no_file).not_to be_valid
    end
  end

  describe 'Associations' do
    # it { is_expected.to have_many(:email_processing_records) }

    it { is_expected.to have_one_attached(:eml_file) }
  end
  describe 'Active Storage functionality' do
    let(:archived_email) { create(:archived_email) }

    it 'can be accessed via the attachment method' do
      expect(archived_email.eml_file).to be_present
    end
  end
end
