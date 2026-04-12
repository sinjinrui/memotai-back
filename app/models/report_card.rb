class ReportCard < ApplicationRecord
  extend Enumerize

  REASON_LIST = %w[
    ゲームと無関係な内容
    差別的または攻撃的な内容
    公序良俗に反する内容
  ].freeze

  belongs_to :user
  belongs_to :card

  with_options presence: true do
    validates :user_id
    validates :card_id
  end

  def self.reason_text
    {
      "001": "ゲームと無関係な内容",
      "002": "差別的または攻撃的な内容",
      "003": "公序良俗に反する内容"
    }
  end

  enumerize :reason, in: REASON_LIST
end
