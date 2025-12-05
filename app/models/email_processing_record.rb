class EmailProcessingRecord < ApplicationRecord
  enum :processing_status, {
    pending: 0,
    success: 1,
    failure: 2
  }, default: :pending

  belongs_to :archived_email
  belongs_to :customer, optional: true

  validates :processed_file_name, presence: true
  validates :processing_status, presence: true

  validates :extracted_data_json, presence: true, if: :success?
  validates :customer, presence: true, if: :success?

  validates :error_details, absence: true, unless: :failure?

  validates :extracted_data_json, absence: true, unless: :success?
  validates :customer, absence: true, unless: :success?

  validates :error_details, presence: true, if: :failure?
end
