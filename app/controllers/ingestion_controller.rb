class IngestionController < ApplicationController
  def index
  end

  def create
    uploaded_file = params.require(:eml_file)

    result = Email::IngestFile.call(uploaded_file: uploaded_file)

    if result[:success]
      flash[:notice] = "Arquivo enviado com sucesso. Processando..."
      redirect_to root_path(status: :scheduled)
    else
      flash[:alert] = "Falha ao processar o arquivo: #{result[:error]}"
      redirect_to root_path(status: :failed)
    end
  rescue ActionController::ParameterMissing
    flash[:alert] = "Por favor, selecione um arquivo .eml para upload."
    redirect_to root_path
  end
end
