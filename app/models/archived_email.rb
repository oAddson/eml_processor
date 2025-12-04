class ArchivedEmail < ApplicationRecord
  has_one_attached :eml_file
  # has_many :email_processing_records
  validates :eml_file, presence: true
  validates :original_file_name, presence: true

  has_many :email_processing_records, dependent: :destroy
end
