require 'rails_helper'

RSpec.describe Email::ExtractData do
  let(:log_record) { create(:email_processing_record) }
  let(:service_call) { described_class.call(log_record: log_record) }

  let(:email_content_success) do
    "From: loja@fornecedora.com\nSubject: Pedido\n\nNome do cliente: João\nE-mail: joao@test.com\nTelefone: 12345678"
  end
  let(:extracted_data_success) do
    { client_name: 'João', client_email: 'joao@test.com', client_phone: '12345678', product_code: nil, email_subject: 'Pedido' }
  end

  let(:email_content_fail_validation) do
    "From: contato@parceirob.com\nSubject: Info\n\nNome completo: Ana\nProduto: PROD-101"
  end

  let(:email_content_unknown) do
    "From: desconhecido@outro.com\nSubject: Teste"
  end


  before do
    allow(log_record.archived_email.eml_file).to receive(:download).and_return(email_content_success)

    allow_any_instance_of(Email::ProcessingContext).to receive(:process_and_extract).and_return(extracted_data_success)
  end

  before do
    allow_any_instance_of(Customer).to receive(:must_have_email_or_phone).and_return(true)
  end

  describe '#call - Sucesso Completo' do
    it 'cria um novo registro Customer' do
      expect { service_call }.to change(Customer, :count).by(1)
    end

    it 'retorna { success: true }' do
      expect(service_call[:success]).to be true
    end

    it 'atualiza o log para status :success' do
      service_call
      expect(log_record.reload.success?).to be true
    end

    it 'associa o Customer criado ao LeadCaptureAttempt' do
      service_call
      customer = Customer.last
      expect(log_record.reload.customer).to eq(customer)
    end
  end

  describe '#call - Falha na Extração/Contexto' do
    before do
      # Simula a falha na extração, lançando uma exceção (ex: validação de contato falhou)
      allow_any_instance_of(Email::ProcessingContext).to receive(:process_and_extract).and_raise(StandardError, 'Falha simulada na extração.')
    end

    it 'não cria um registro Customer' do
      expect { service_call }.not_to change(Customer, :count)
    end

    it 'atualiza o log para status :failure' do
      service_call
      expect(log_record.reload.failure?).to be true
    end

    it 'salva a mensagem de erro no log' do
      service_call
      expect(log_record.reload.error_details).to eq('Falha simulada na extração.')
    end

    it 'retorna { success: false }' do
      expect(service_call[:success]).to be false
    end
  end
end
