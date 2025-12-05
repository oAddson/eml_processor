require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:full_name) }
  end

  describe 'Custom Contact Validation' do
    context 'when both email and phone are present' do
      it 'is valid' do
        customer = Customer.new(email: 'a@a.com', phone: '123456789')
        customer.full_name = "Test"
        expect(customer).to be_valid
      end
    end

    context 'when only email is present' do
      it 'is valid' do
        customer = Customer.new(email: 'a@a.com', phone: nil)
        customer.full_name = "Test"
        expect(customer).to be_valid
      end
    end

    context 'when only phone is present' do
      it 'is valid' do
        customer = Customer.new(email: nil, phone: '123456789')
        customer.full_name = "Test"
        expect(customer).to be_valid
      end
    end

    context 'when both email and phone are missing (nil)' do
      it 'is invalid and adds an error message' do
        customer = Customer.new(email: nil, phone: nil)
        customer.full_name = "Test"
        expect(customer).not_to be_valid
        expect(customer.errors[:base]).to include("É obrigatório fornecer o e-mail ou o telefone.")
      end
    end
  end
end
