require 'rails_helper'

RSpec.describe EmailProcessingRecordsController, type: :request do
  before do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:signed_id).and_return("fake_signed_id")
  end

  let(:no_file_email) { create(:archived_email, :without_file) }

  let!(:archived_email) { create(:archived_email) }
  let!(:customer) { create(:customer) }

  let!(:log_success) { create(:email_processing_record, :success, archived_email: archived_email, customer: customer, created_at: 1.day.ago) }
  let!(:log_failure) { create(:email_processing_record, :failure, archived_email: archived_email, created_at: 2.days.ago) }
  let!(:log_pending) { create(:email_processing_record, :pending, archived_email: archived_email, created_at: 3.days.ago) }

  describe "GET #index" do
    before { get email_processing_records_path }

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "loads all EmailProcessingRecord records" do
      expect(assigns(:logs).count).to eq(3)
    end

    it "orders the logs by created_at in descending order" do
      expect(assigns(:logs)).to eq([ log_success, log_failure, log_pending ])
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    context "when the EmailProcessingRecord exists" do
      before { get email_processing_records_path(log_success) }

      it "returns a successful response" do
        expect(response).to be_successful
      end
    end

    context "when the EmailProcessingRecord does not exist" do
      before { get email_processing_records_path(id: 9999) }

      it "assigns @log as nil" do
        expect(assigns(:log)).to be_nil
      end

      it "returns a successful response (renders the show view with nil log)" do
        expect(response).to be_successful
      end
    end
  end


  describe "POST #reprocess" do
    let(:eml_file_path) { Rails.root.join('spec', 'emails', "email1.eml") }
    let(:archived_email) { create(:archived_email, eml_file: Rack::Test::UploadedFile.new(eml_file_path, 'message/rfc822')) }
    let!(:log_record) { create(:email_processing_record, :failure, archived_email: archived_email) }

    context 'when reprocess service succeeds' do
      let(:new_log_record) { build_stubbed(:email_processing_record, id: 100) }
      let(:service_result) { { success: true, data: new_log_record } }
      let(:reprocess_service) { instance_double(Email::ReprocessFile) }

      before do
        allow(Email::ReprocessFile).to receive(:call).and_return(service_result)
      end
      it 'calls the Email::ReprocessFile service' do
        post reprocess_email_processing_record_path(log_record)
        expect(Email::ReprocessFile).to have_received(:call).with(log_record: log_record)
      end

      it 'redirects to the logs index path' do
        post reprocess_email_processing_record_path(log_record)
        expect(response).to redirect_to(email_processing_records_path)
      end

      it 'sets a success flash message with the new log ID' do
        post reprocess_email_processing_record_path(log_record)
        expect(flash[:notice]).to include("Novo log ID: #{new_log_record.id}")
      end
    end

    context 'when log record is not found' do
      it 'redirects to the logs index path' do
        post reprocess_email_processing_record_path(999)
        expect(response).to redirect_to(email_processing_records_path)
      end

      it 'sets an alert flash message' do
        post reprocess_email_processing_record_path(999)
        expect(flash[:alert]).to eq("Upload não encontrado!")
      end
    end
  end


  describe "GET #download_file" do
    let(:eml_file_path) { Rails.root.join('spec', 'emails', "email1.eml") }
    let(:archived_email) { create(:archived_email, eml_file: Rack::Test::UploadedFile.new(eml_file_path, 'message/rfc822')) }
    let!(:log_record) { create(:email_processing_record, :success, archived_email: archived_email) }

    context 'when the file is attached' do
      it 'redirects to the Active Storage blob path (download)' do
        get download_file_email_processing_record_path(log_record)
        expect(response).to redirect_to(rails_blob_path(archived_email.eml_file, disposition: "attachment"))
      end
    end
  end
end
