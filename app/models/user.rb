class User < ApplicationRecord
  extend Enumerize

  RANK_LIST = [
    "Rookie", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Diamond",
    "Master", "High Master", "Grand Master", "Ultimate Master"
  ].freeze

  enumerize :rank, in: RANK_LIST, allow_nil: true

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
    format: { with: /\A[A-Za-z0-9]+\z/ },
    allow_nil: true

  scope :registered, -> { where(is_guest: false) }
end
