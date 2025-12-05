class Customer < ApplicationRecord
  validates :full_name, presence: true
  validate :must_have_email_or_phone
  has_many :email_processing_records

  before_validation :normalize_phone

  private

  def must_have_email_or_phone
    if email.blank? && phone.blank?
      errors.add(:base, "É obrigatório fornecer o e-mail ou o telefone.")
    end
  end

  def normalize_phone
    return if phone.blank?

    cleaned_phone = phone.gsub(/[^0-9]/, "")

    unless cleaned_phone.start_with?("55")
      if cleaned_phone.length >= 10 && cleaned_phone.length <= 13
        cleaned_phone = "55#{cleaned_phone}"
      end
    end

    self.phone = "+#{cleaned_phone}"
  end
end
