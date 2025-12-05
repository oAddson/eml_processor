require 'rails_helper'

RSpec.describe Email::Parser::FornecedorA do
  # Simula o e-mail 1.eml (Sucesso Completo)
  let(:full_email_content) do
    "From: loja@fornecedorA.com\nSubject: Pedido de orçamento - Produto ABC123\n\n" +
    "Olá equipe,\n\nGostaria de solicitar informações sobre o produto de código ABC123.\n\n" +
    "Nome do cliente: João da Silva\nE-mail: joao.silva@example.com\nTelefone: (11) 91234-5678\n"
  end
  let(:parser) { described_class.new(email_body: full_email_content) }

  before do
    parser.extract
  end

  describe '#extract - E-mail Completo (1.eml)' do
    it 'extrai corretamente o Nome do cliente' do
      expect(parser.extracted_data[:client_name]).to eq('João da Silva')
    end

    it 'extrai corretamente o E-mail do cliente' do
      expect(parser.extracted_data[:client_email]).to eq('joao.silva@example.com')
    end

    it 'extrai corretamente o Telefone do cliente' do
      expect(parser.extracted_data[:client_phone]).to eq('(11) 91234-5678')
    end

    it 'extrai o código do produto do corpo do e-mail' do
      expect(parser.extracted_data[:product_code]).to eq('ABC123')
    end

    it 'extrai o assunto do e-mail' do
      expect(parser.extracted_data[:email_subject]).to eq('Pedido de orçamento - Produto ABC123')
    end
  end

  describe '#contact_info_present?' do
    context 'quando email e telefone estão presentes' do
      it 'retorna true' do
        expect(parser.contact_info_present?).to be true
      end
    end

    context 'quando ambos email e telefone estão ausentes (email7.eml)' do
      let(:fail_email_content) do
        "From: loja@fornecedorA.com\nSubject: Solicitação de cotação - Produto LMN456\n\n" +
        "Bom dia,\n\nTenho interesse no produto LMN456.\n\nNome: Pedro Santos\n"
      end
      let(:fail_parser) { described_class.new(email_body: fail_email_content) }

      before { fail_parser.extract }

      it 'retorna false' do
        expect(fail_parser.contact_info_present?).to be false
      end
    end
  end
end
