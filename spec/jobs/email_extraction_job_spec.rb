require 'rails_helper'

RSpec.describe EmailExtractionJob, type: :job do
  it 'queues the job into the default queue' do
    expect(described_class.queue_name).to eq('default')
  end

  let!(:archived_email) { create(:archived_email) }
  let!(:log_record) { create(:email_processing_record, :pending, archived_email: archived_email) }
  let(:service_result) { { success: true, data: { customer_id: 1 } } }

  before do
    allow(Email::ExtractData).to receive(:call).and_return(service_result)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  context 'when the record exists' do
    context 'and the extraction succeeds' do
      let(:service_result) { { success: true, data: { customer_id: 1 } } }

      it 'calls the Email::ExtractData service with the correct record' do
        described_class.perform_now(email_processing_record_id: log_record.id)
        expect(Email::ExtractData).to have_received(:call).with(log_record: log_record)
      end

      it 'logs a success message' do
        described_class.perform_now(email_processing_record_id: log_record.id)
        expect(Rails.logger).to have_received(:info).with("Job ##{log_record.id}: Extração concluída com sucesso.")
      end
    end

    context 'and the extraction fails' do
      let(:error_message) { "Parser não encontrou o campo de telefone." }
      let(:service_result) { { success: false, error: error_message } }

      it 'calls the Email::ExtractData service' do
        described_class.perform_now(email_processing_record_id: log_record.id)
        expect(Email::ExtractData).to have_received(:call).with(log_record: log_record)
      end

      it 'logs an error message with failure details' do
        described_class.perform_now(email_processing_record_id: log_record.id)
        expect(Rails.logger).to have_received(:error).with("Job ##{log_record.id}: Falha na extração. Erro: #{error_message}")
      end
    end
  end

  context 'when the EmailProcessingRecord is not found' do
    it 'returns immediately without calling the extraction service' do
      described_class.perform_now(email_processing_record_id: 9999)
      expect(Email::ExtractData).not_to have_received(:call)
    end
  end
end
