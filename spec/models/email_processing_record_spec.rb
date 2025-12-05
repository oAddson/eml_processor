require 'rails_helper'

RSpec.describe EmailProcessingRecord, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:archived_email) }

    it { is_expected.to belong_to(:customer).optional }
  end


  describe 'Validations and Status' do
    it { is_expected.to validate_presence_of(:processed_file_name) }

    it { is_expected.to validate_presence_of(:processing_status) }

    it { is_expected.to define_enum_for(:processing_status).with_values([ :pending, :success, :failure ]) }

    context 'when status is success' do
      subject { build(:email_processing_record, :success, customer: nil, extracted_data_json: nil) }

      it 'is valid when all required fields are present' do
        expect(build(:email_processing_record, :success)).to be_valid
      end

      it 'validates presence of extracted_data_json' do
        expect(build(:email_processing_record, :success, extracted_data_json: nil)).not_to be_valid
      end

      it 'validates presence of customer' do
        expect(build(:email_processing_record, :success, customer: nil)).not_to be_valid
      end

      it 'validates absence of error_details' do
        expect(build(:email_processing_record, :success, error_details: 'Erro aqui')).not_to be_valid
      end
    end

    context 'when status is failure' do
      it 'is valid when error details are present' do
        expect(build(:email_processing_record, :failure)).to be_valid
      end

      it 'validates presence of error_details' do
        expect(build(:email_processing_record, :failure, error_details: nil)).not_to be_valid
      end

      it 'validates absence of extracted_data_json' do
        expect(build(:email_processing_record, :failure, extracted_data_json: { key: 'value' })).not_to be_valid
      end

      it 'validates absence of customer' do
        expect(build(:email_processing_record, :failure, customer: create(:customer))).not_to be_valid
      end
    end

    context 'when status is pending' do
      it 'is valid without extracted data or error details' do
        expect(build(:email_processing_record, :pending)).to be_valid
      end

      it 'validates absence of extracted_data_json' do
        expect(build(:email_processing_record, :pending, extracted_data_json: { key: 'value' })).not_to be_valid
      end

      it 'validates absence of error_details' do
        expect(build(:email_processing_record, :pending, error_details: 'Detalhe')).not_to be_valid
      end

      it 'validates absence of customer' do
        expect(build(:email_processing_record, :pending, customer: create(:customer))).not_to be_valid
      end
    end
  end
end
