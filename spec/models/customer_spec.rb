require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }

    it 'validates uniqueness of email' do
      create(:customer)
      is_expected.to validate_uniqueness_of(:email).case_insensitive
    end
  end

  describe 'Associations' do
  end
end
