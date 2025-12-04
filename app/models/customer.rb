class Customer < ApplicationRecord
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
