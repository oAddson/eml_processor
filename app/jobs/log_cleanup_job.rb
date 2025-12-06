class LogCleanupJob < ApplicationJob
  queue_as :low_priority
  RETENTION_TIME = 30.days

  def perform
    Rails.logger.info "Iniciando limpeza periódica de logs..."
    records_deleted = EmailProcessingRecord
                      .where("created_at <= ?", Time.current - RETENTION_TIME)
                      .delete_all

    Rails.logger.info "Limpeza concluída. Total de #{records_deleted} logs de processamento deletados."
  end
end
