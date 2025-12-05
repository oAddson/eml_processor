require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  let!(:archived_email) { create(:archived_email) }
  let!(:log_record) { create(:email_processing_record, :success, archived_email: archived_email) }
  let(:customer) { log_record.customer }
  let!(:unrelated_customer) { create(:customer, full_name: "Unrelated User") }

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    before { get :show, params: { id: customer.id } }

    context "when the Customer exists" do
      it "returns http success" do # Use http status instead of response methods in controller specs
        expect(response).to have_http_status(:success)
      end

      it "loads the correct Customer record" do
        expect(assigns(:customer)).to eq(customer)
      end

      it "loads the related log record" do
        expect(assigns(:related_log)).to eq(log_record)
      end
    end
  end
end
