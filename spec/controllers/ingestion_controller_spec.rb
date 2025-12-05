require 'rails_helper'

RSpec.describe IngestionController, type: :request do
  let(:eml_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'emails', "email1.eml"), 'message/rfc822') }
  let(:ingest_file_service) { instance_double(Email::IngestFile) }
  let(:params) { { eml_file: eml_file } }

  describe "GET #index" do
    it "renders a successful response" do
      get root_path
      expect(response).to be_successful
    end

    it "displays the upload form content" do
      get root_path
      expect(response.body).to include("Ingestão de E-mails para Processamento")
    end
  end


  describe "POST #create" do
    context "when the service returns success" do
      let(:service_result) { { success: true, data: 'log_record_dummy' } }

      before do
        allow(Email::IngestFile).to receive(:call).and_return(service_result)
      end

      it "calls the Email::IngestFile service" do
        post ingestion_index_path, params: params
        expect(Email::IngestFile).to have_received(:call).with(uploaded_file: an_instance_of(ActionDispatch::Http::UploadedFile))
      end

      it "redirects to the scheduled status" do
        post ingestion_index_path, params: params
        expect(response).to redirect_to(root_path(status: :scheduled))
      end

      it "sets a success flash message" do
        post ingestion_index_path, params: params
        expect(flash[:notice]).to eq("Arquivo enviado com sucesso. Processando...")
      end
    end

    context "when the service returns failure" do
      let(:error_message) { "O nome do cliente não pôde ser extraído." }
      let(:service_result) { { success: false, error: error_message } }

      before do
        allow(Email::IngestFile).to receive(:call).and_return(service_result)
      end

      it "redirects to the failed status" do
        post ingestion_index_path, params: params
        expect(response).to redirect_to(root_path(status: :failed))
      end

      it "sets an alert flash message with the error details" do
        post ingestion_index_path, params: params
        expect(flash[:alert]).to include(error_message)
      end
    end

    context "when no file is uploaded (ActionController::ParameterMissing)" do
      let(:params) { {} }

      it "sets an alert flash message" do
        post ingestion_index_path, params: params
        expect(flash[:alert]).to eq("Por favor, selecione um arquivo .eml para upload.")
      end

      it "redirects to the root path" do
        post ingestion_index_path, params: params
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
