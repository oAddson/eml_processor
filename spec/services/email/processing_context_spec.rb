require 'rails_helper'

RSpec.describe Email::ProcessingContext do
  let(:log_record) { create(:email_processing_record) }

  def setup_email_attachment(content)
    allow(log_record.archived_email.eml_file).to receive(:download).and_return(content)
  end

  describe '#process_and_extract - Regra de Contato' do
    context 'quando o parser retorna contato válido (Email presente)' do
      let(:content) { "From: loja@fornecedora.com\nSubject: Teste\n\nNome: João\nE-mail: joao@a.com" }

      it 'retorna os dados extraídos sem lançar exceção' do
        setup_email_attachment(content)
        context = Email::ProcessingContext.new(archived_email: log_record.archived_email)
        expect { context.process_and_extract }.not_to raise_error
      end
    end

    context 'quando o parser NÃO retorna contato válido (apenas Nome e Produto)' do
      let(:content) { "From: contato@parceirob.com\nSubject: Info\n\nNome completo: Ana\nProduto: PROD-101" }

      it 'lança um erro indicando que as informações de contato estão ausentes' do
        setup_email_attachment(content)
        context = Email::ProcessingContext.new(archived_email: log_record.archived_email)
        expect { context.process_and_extract }.to raise_error(StandardError, 'Falha na extração: Informações de contato (e-mail/telefone) ausentes.')
      end
    end
  end
end
