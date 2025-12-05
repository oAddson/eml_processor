module Email
  module Parser
    class Base
      attr_reader :email_body, :subject, :data

      def initialize(email_body:)
        @email_body = email_body
        @subject = extract_subject
        @data = {}
      end

      def extract
        raise NotImplementedError, "#{self.class.name} deve implementar o método #extract"
      end

      def extracted_data
        @data.merge(email_subject: extract_subject)
      end

      def extract_subject
        @email_body.match(/^Subject:\s*(.*?)(?:\r?\n[\s\t]+.*?)?\r?\n/im)[1]
      end

      def contact_info_present?
        @data[:client_email].present? || @data[:client_phone].present?
      end

      protected

      def clean_text(text)
        text.to_s.strip
      end
    end
  end
end
