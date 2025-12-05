module Email
  class IngestFile
    def self.call(uploaded_file:)
      new(uploaded_file).call
    end

    def initialize(uploaded_file)
      @uploaded_file = uploaded_file
    end

    def call
      ActiveRecord::Base.transaction do
        archived_email = create_archived_email!

        log_record = create_pending_log!(archived_email)

        { success: true, data: log_record }
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "IngestFile falhou (Validação): #{e.message}"
      { success: false, error: e.message }
    rescue StandardError => e
      Rails.logger.error "IngestFile falhou (Sistema): #{e.message}"
      { success: false, error: e.message }
    end

    private

    def create_archived_email!
      ArchivedEmail.create!(
        original_file_name: @uploaded_file.original_filename,
        archive_date: Time.current,
        eml_file: {
          io: @uploaded_file.open,
          filename: @uploaded_file.original_filename,
          content_type: @uploaded_file.content_type
        }
      )
    end

    def create_pending_log!(archived_email)
      EmailProcessingRecord.create!(
        archived_email: archived_email,
        processed_file_name: archived_email.original_file_name,
        processing_status: :pending,
        extracted_data_json: nil,
        error_details: nil
      )
    end
  end
end
