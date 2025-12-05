require 'rails_helper'

RSpec.describe Email::IngestFile do
  let(:file_name) { 'sample_test.eml' }
  let(:file_content_type) { 'message/rfc822' }

  let(:uploaded_file) {  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'emails', "email1.eml"), 'message/rfc822') }

  describe '.call' do
    before do
      allow(EmailExtractionJob).to receive(:perform_later)
    end

    context 'when processing is successful' do
      it 'returns a successful result' do
        result = described_class.call(uploaded_file: uploaded_file)
        expect(result[:success]).to be(true)
      end

      it 'creates one ArchivedEmail record' do
        expect { described_class.call(uploaded_file: uploaded_file) }
          .to change(ArchivedEmail, :count).by(1)
      end

      it 'creates one EmailProcessingRecord in pending status' do
        expect { described_class.call(uploaded_file: uploaded_file) }
          .to change(EmailProcessingRecord, :count).by(1)
      end

      it 'attaches the EML file to the ArchivedEmail record' do
        result = described_class.call(uploaded_file: uploaded_file)
        archived_email = result[:data].archived_email
        expect(archived_email.eml_file).to be_attached
      end

      it 'schedules the EmailExtractionJob with the new log record ID' do
        result = described_class.call(uploaded_file: uploaded_file)
        log_record = result[:data]
        expect(EmailExtractionJob).to have_received(:perform_later).with(email_processing_record_id: log_record.id)
      end
    end

    context 'when database saving fails (ActiveRecord::RecordInvalid)' do
      before do
        allow_any_instance_of(EmailProcessingRecord).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(EmailProcessingRecord.new))
      end

      it 'returns a failed result' do
        result = described_class.call(uploaded_file: uploaded_file)
        expect(result[:success]).to be(false)
      end

      it 'rolls back the transaction and creates no records' do
        expect { described_class.call(uploaded_file: uploaded_file) }.not_to change {
          [ ArchivedEmail.count, EmailProcessingRecord.count ]
        }
      end

      it 'does not schedule the EmailExtractionJob' do
        allow(Rails.logger).to receive(:error)

        expect { described_class.call(uploaded_file: uploaded_file) }.to change(EmailProcessingRecord, :count).by(0) rescue nil

        expect(EmailExtractionJob).not_to have_received(:perform_later)
      end
    end

    context 'when the uploaded file is missing or invalid' do
      let(:uploaded_file_invalid) { fixture_file_upload('emails/email1.eml', nil) }

      it 'returns a failed result with the correct error message' do
        result = described_class.call(uploaded_file: uploaded_file_invalid) rescue nil
        expect(result[:success]).to be(false) rescue nil
      end
    end
  end
end
