class User < ApplicationRecord
  has_secure_password

  has_many :cards, dependent: :delete_all
  has_many :report_cards, dependent: :delete_all
  validates :login_id,
    presence: true,
    length: { in: 4..16 },
    format: { with: /\A[a-zA-Z0-9_]+\z/ },
    uniqueness: true

  validates :password,
    length: { in: 8..32 },
    format: { with: /\A[A-Za-z0-9]+\z/ }

  scope :registered, -> { where(is_guest: false) }
end
