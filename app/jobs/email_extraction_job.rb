class EmailExtractionJob < ApplicationJob
  queue_as :default

  def perform(email_processing_record_id:)
    log_record = EmailProcessingRecord.find_by(id: email_processing_record_id)
    return unless log_record

    result = Email::ExtractData.call(log_record: log_record)

    if result[:success]
      Rails.logger.info "Job ##{log_record.id}: Extração concluída com sucesso."
    else
      Rails.logger.error "Job ##{log_record.id}: Falha na extração. Erro: #{result[:error]}"
    end
  end
end
