class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cards, through: :card_tags
  validates :name, presence: true, length: { maximum: 20 }
end
