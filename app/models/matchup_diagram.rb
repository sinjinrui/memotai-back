class MatchupDiagram < ApplicationRecord
  validates :rank, :character_code, :enemy_code, :season, presence: true
  validates :rank, inclusion: { in: User::RANK_LIST }
  validates :win_rate, presence: true, numericality: true
  validates :character_code, inclusion: { in: Card::CODE_LIST }
  validates :enemy_code, inclusion: { in: Card::CODE_LIST }
  validates :character_code, uniqueness: { scope: [ :enemy_code, :rank ] }
end
