
module Email
  module Parser
    class ParceiroB < Base
      def extract
        @data[:client_name]  = clean_text(email_body[/(Nome completo|Cliente|Nome do cliente): (.*?)\n/i, 2])

        @data[:client_email] = clean_text(email_body[/(E-mail de contato|Email): (.*?)\n/i, 2])

        @data[:client_phone] = clean_text(email_body[/Telefone: (.*?)\n/i, 1])

        @data[:product_code] = clean_text(email_body[/(Código do produto|Produto de interesse): (PROD-\d+)/i, 2] ||
                                           subject[/PROD-(\d+)/i, 0])

        @data.compact_blank!
      end
    end
  end
end
