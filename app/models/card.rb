class Card < ApplicationRecord
  extend Enumerize

  CODE_LIST = %w[
    001 002 003 004 005 006 007 008 009 010
    011 012 013 014 015 016 017 018 019 020
    021 022 023 024 025 026 027 028 029 030
    031
    000
  ].freeze

  CHARACTER_NAMES = {
    "000" => "COMMON",
    "001" => "RYU",
    "002" => "LUKE",
    "003" => "JAMIE",
    "004" => "CHUN-LI",
    "005" => "GUILE",
    "006" => "KIMBERLY",
    "007" => "JURI",
    "008" => "KEN",
    "009" => "BLANKA",
    "010" => "DHALSIM",
    "011" => "E.HONDA",
    "012" => "DEE JAY",
    "013" => "MANON",
    "014" => "MARISA",
    "015" => "JP",
    "016" => "ZANGIEF",
    "017" => "LILY",
    "018" => "CAMMY",
    "019" => "RASHID",
    "020" => "A.K.I.",
    "021" => "ED",
    "022" => "GOUKI",
    "023" => "VEGA",
    "024" => "TERRY",
    "025" => "MAI",
    "026" => "ELENA",
    "027" => "SAGAT",
    "028" => "C.VIPER",
    "029" => "ALEX",
    "030" => "INGRID",
    "031" => "YASMINE"
  }.freeze

  belongs_to :user
  has_many :report_cards
  has_many :card_tags, dependent: :destroy
  has_many :tags, through: :card_tags

  with_options presence: true do
    validates :user_id
    validates :character_code
    validates :enemy_code
  end
  validates :text, length: { maximum: 140 }
  validates :embed_url, format: {
    with: /\A(https?:\/\/(www\.)?(youtube\.com\/watch\?.*v=|youtu\.be\/|youtube\.com\/live\/|youtube\.com\/shorts\/|x\.com\/\w+\/status\/)[\w\-?=&]+)\z/,
    message: "はYouTubeまたはXのURLを入力してください"
  }, allow_blank: true

  acts_as_list scope: [
    :user_id,
    :character_code,
    :enemy_code,
    archived_at: nil
  ]

  enumerize :character_code, in: CODE_LIST, scope: true # card.with_character_code("001")
  enumerize :enemy_code, in: CODE_LIST, scope: true # card.with_enemy_code("002")

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
end
