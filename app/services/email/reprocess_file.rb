
module Email
  class ReprocessFile
    def self.call(log_record:)
      new(log_record).call
    end

    def initialize(log_record)
      @old_log = log_record
      @archived_email = log_record.archived_email
    end

    def call
      ActiveRecord::Base.transaction do
        new_log = create_new_pending_log!

        { success: true, data: new_log }
      end
    rescue StandardError => e
      Rails.logger.error "ReprocessFile falhou para o log #{@old_log.id}: #{e.message}"
      { success: false, error: "Falha ao agendar reprocessamento." }
    end

    private

    def create_new_pending_log!
      EmailProcessingRecord.create!(
        archived_email: @archived_email,
        processed_file_name: @archived_email.original_file_name,
        processing_status: :pending
      )
    end
  end
end
