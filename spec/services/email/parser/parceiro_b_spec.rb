require 'rails_helper'

RSpec.describe Email::Parser::ParceiroB do
  # Simula o e-mail 4.eml (Sucesso Completo)
  let(:full_email_content) do
    "From: contato@parceiroB.com\nSubject: Cliente interessado no PROD-555\n\n" +
    "Equipe,\n\nSegue solicitação recebida:\n\nCliente: Ana Costa\n" +
    "Email: ana.costa@example.com\nTelefone: +55 31 97777-1111\n" +
    "Produto de interesse: PROD-555\n"
  end
  let(:parser) { described_class.new(email_body: full_email_content) }

  before do
    parser.extract
  end

  describe '#extract - E-mail Completo (4.eml)' do
    it 'extrai corretamente o Nome do cliente' do
      expect(parser.extracted_data[:client_name]).to eq('Ana Costa')
    end

    it 'extrai corretamente o E-mail do cliente' do
      expect(parser.extracted_data[:client_email]).to eq('ana.costa@example.com')
    end

    it 'extrai corretamente o Telefone do cliente' do
      expect(parser.extracted_data[:client_phone]).to eq('+55 31 97777-1111')
    end

    it 'extrai o código do produto do corpo do e-mail' do
      expect(parser.extracted_data[:product_code]).to eq('PROD-555')
    end

    it 'extrai o assunto do e-mail' do
      expect(parser.extracted_data[:email_subject]).to eq('Cliente interessado no PROD-555')
    end
  end

  describe '#contact_info_present? - Falha de Contato' do
    context 'quando apenas o telefone está presente (email6.eml)' do
      let(:phone_only_content) do
        "From: contato@parceiroB.com\nSubject: Pedido de informações - PROD-999\n\n" +
        "Olá,\n\nNome do cliente: Fernanda Lima\nTelefone: 61 93333-4444\nProduto: PROD-999\n"
      end
      let(:phone_parser) { described_class.new(email_body: phone_only_content) }

      before { phone_parser.extract }

      it 'retorna true' do
        expect(phone_parser.contact_info_present?).to be true
      end
    end

    context 'quando contato está ausente (email8.eml)' do
      let(:no_contact_content) do
        "From: contato@parceiroB.com\nSubject: Pedido de informações - PROD-999\n\n" +
        "Olá,\n\nNome do cliente: Fernanda Lima\nProduto: PROD-999\n"
      end
      let(:no_contact_parser) { described_class.new(email_body: no_contact_content) }

      before { no_contact_parser.extract }

      it 'retorna false (regra de negócio falha)' do
        expect(no_contact_parser.contact_info_present?).to be false
      end
    end
  end
end
