require 'rails_helper'

# Cria uma classe de teste que herda da Base para podermos instanciá-la e testar os métodos protegidos/públicos.
class DummyParser < Email::Parser::Base
  def extract
    # Implementação dummy para satisfazer o TDD, se necessário para fluxos complexos.
    @data[:client_email] = 'test@example.com' # Sucesso
  end

  # Expondo o método protected para fins de teste
  def exposed_clean_text(text)
    clean_text(text)
  end
end

RSpec.describe Email::Parser::Base, type: :service do
  let(:email_content) do
    "From: teste@exemplo.com\r\n" +
    "Subject: Pedido de cotação para Produto XYZ\r\n" +
    "Content-Type: text/plain\r\n\r\n" +
    "Corpo do email aqui.\r\n"
  end
  let(:parser) { DummyParser.new(email_body: email_content) }

  describe '#initialize' do
    it 'inicializa o email_body' do
      expect(parser.email_body).to eq(email_content)
    end

    it 'inicializa o hash de dados (data) como vazio' do
      expect(parser.data).to eq({})
    end

    it 'chama #extract_subject para preencher o subject' do
      # Teste para garantir que a extração do subject é feita na inicialização
      expect(parser.subject).to eq('Pedido de cotação para Produto XYZ')
    end
  end

  describe '#extract_subject' do
    context 'quando o subject é simples' do
      it 'extrai corretamente o subject do email_body' do
        expect(parser.extract_subject).to eq('Pedido de cotação para Produto XYZ')
      end
    end

    context 'quando o subject contém múltiplas linhas ou quebras de linha complexas' do
      let(:complex_content) do
        "Subject: Pedido de cotação\r\n \tpara Produto XYZ\r\n\r\n"
      end
      let(:complex_parser) { DummyParser.new(email_body: complex_content) }

      it 'extrai apenas a primeira linha do subject e ignora as subsequentes' do
        expect(complex_parser.extract_subject).to eq('Pedido de cotação')
      end
    end
  end

  describe '#extracted_data' do
    it 'inclui o assunto do e-mail no hash de dados' do
      # O método dummy implementa a extração
      parser.extract
      data = parser.extracted_data
      expect(data).to include(email_subject: 'Pedido de cotação para Produto XYZ')
    end
  end

  describe '#contact_info_present?' do
    it 'retorna false quando data está vazio' do
      expect(parser.contact_info_present?).to be false
    end

    it 'retorna true quando :client_email está presente' do
      parser.data[:client_email] = 'a@b.com'
      expect(parser.contact_info_present?).to be true
    end

    it 'retorna true quando :client_phone está presente' do
      parser.data[:client_phone] = '987654321'
      expect(parser.contact_info_present?).to be true
    end

    it 'retorna true quando ambos estão presentes' do
      parser.data[:client_email] = 'a@b.com'
      parser.data[:client_phone] = '987654321'
      expect(parser.contact_info_present?).to be true
    end

    it 'retorna false quando ambos estão em branco' do
      parser.data[:client_email] = ''
      parser.data[:client_phone] = nil
      expect(parser.contact_info_present?).to be false
    end
  end

  describe 'protected #clean_text' do
    # Usamos o método exposto na DummyParser
    it 'remove espaços em branco no início e fim da string' do
      expect(parser.exposed_clean_text("  texto com espaço \n")).to eq('texto com espaço')
    end

    it 'converte nil para string vazia antes de limpar' do
      expect(parser.exposed_clean_text(nil)).to eq('')
    end
  end
end
