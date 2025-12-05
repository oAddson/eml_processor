class Customer < ApplicationRecord
  validates :full_name, presence: true
  validate :must_have_email_or_phone

  def must_have_email_or_phone
    if email.blank? && phone.blank?
      errors.add(:base, "É obrigatório fornecer o e-mail ou o telefone.")
    end
  end
end
