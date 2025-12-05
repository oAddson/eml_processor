class CustomersController < ApplicationController
  def index
    @customers = Customer.order(created_at: :desc)
  end

  def show
    @customer = Customer.find_by_id(params[:id])

    @related_log = @customer.email_processing_records.find_by(customer: @customer)
  end
end
