
module Email
  module Parser
    class FornecedorA < Base
      def extract
        @data[:client_name]  = clean_text(email_body[/Nome( do cliente)?: (.*?)\n/i, 2])

        @data[:client_email] = clean_text(email_body[/E-mail:\s*([^\s@]+@[^\s@]+\.[^\s@]+)/i, 1])

        @data[:client_phone] = clean_text(email_body[/Telefone: (.*?)\n/i, 1])

        @data[:product_code] = clean_text(email_body[/produto de código (.*?)[\.\n]/i, 1] ||
                                           email_body[/produto (ABC123|XYZ987|LMN456)/i, 1])

        @data.compact_blank!
      end
    end
  end
end
