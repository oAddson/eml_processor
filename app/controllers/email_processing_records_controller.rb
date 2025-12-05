class EmailProcessingRecordsController < ApplicationController
  def index
    @logs = EmailProcessingRecord.includes(:customer).order(created_at: :desc)
  end

  def show
    @log = EmailProcessingRecord.find_by_id(params[:id])
  end

  def reprocess
    @log = EmailProcessingRecord.find_by_id(params[:id])
    unless @log
      flash[:alert] = "Upload não encontrado!"
      return redirect_to email_processing_records_path
    end

    result = Email::ReprocessFile.call(log_record: @log)

    if result[:success]
      flash[:notice] = "Reprocessamento agendado com sucesso! Novo log ID: #{result[:data].id}"
    else
      flash[:alert] = "Falha ao tentar reprocessar o arquivo!"
    end

    redirect_to email_processing_records_path
  end

  def download_file
    @log = EmailProcessingRecord.find_by_id(params[:id])
    archived_email = @log.archived_email

    unless archived_email.eml_file.attached?
      return redirect_to email_processing_records_path, alert: "Arquivo não encontrado para download."
    end

    redirect_to rails_blob_path(archived_email.eml_file, disposition: "attachment")
  rescue ActiveRecord::RecordNotFound
    redirect_to email_processing_records_path, alert: "Log ou arquivo não encontrado."
  end
end
