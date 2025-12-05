module Email
  class ExtractData
    def self.call(log_record:)
      new(log_record).call
    end

    def initialize(log_record)
      @log_record = log_record
      @archived_email = log_record.archived_email
    end

    def call
      ActiveRecord::Base.transaction do
        extracted_data = Email::ProcessingContext.new(archived_email: @archived_email).process_and_extract
        customer = create_customer!(extracted_data)

        update_log_success!(@log_record, extracted_data, customer)

        { success: true, data: extracted_data }

      rescue StandardError => e
        update_log_failure!(@log_record, e.message)

        { success: false, error: e.message }
      end
    end

    private

    def create_customer!(data)
      Customer.create!(
        full_name: data[:client_name],
        email: data[:client_email],
        phone: data[:client_phone],
        product_code: data[:product_code],
        email_subject: data[:email_subject]
      )
    end

    def update_log_success!(log, extracted_data, customer)
      log.update!(
        processing_status: :success,
        extracted_data_json: extracted_data,
        customer: customer,
        error_details: nil
      )
    end

    def update_log_failure!(log, error_message)
      log.update!(
        processing_status: :failure,
        extracted_data_json: nil,
        customer: nil,
        error_details: error_message
      )
    end
  end
end
