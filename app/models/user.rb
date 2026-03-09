class User < ApplicationRecord
  has_secure_password

  has_many :cards, dependent: :delete_all
  validates :login_id, uniqueness: true

  scope :registered, -> { where(is_guest: false) }
end
