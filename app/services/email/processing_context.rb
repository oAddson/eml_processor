module Email
  class ProcessingContext
    attr_reader :archived_email, :email_content

    REMOTE_EMAIL_MAP = {
      "loja@fornecedora.com" => Email::Parser::FornecedorA,
      "contato@parceirob.com"   => Email::Parser::ParceiroB
    }.freeze

    def initialize(archived_email:)
      @archived_email = archived_email
      raw_content = archived_email.eml_file.download
      @email_content = raw_content.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    end

    def process_and_extract
      parser_class = determine_parser_class
      raise StandardError, "Remetente desconhecido ou formato de e-mail não suportado." unless parser_class

      parser = parser_class.new(email_body: @email_content)
      parser.extract

      return parser.extracted_data if parser.contact_info_present?

      raise StandardError, "Falha na extração: Informações de contato (e-mail/telefone) ausentes."
    end

    private

    def determine_parser_class
      sender_email_match = @email_content.match(/From:.*?([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6})/i)

      return nil unless sender_email_match

      sender_email = sender_email_match[1].strip.downcase

      REMOTE_EMAIL_MAP[sender_email]
    end
  end
end
