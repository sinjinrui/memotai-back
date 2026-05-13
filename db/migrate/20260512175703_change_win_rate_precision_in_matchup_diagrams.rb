class ChangeWinRatePrecisionInMatchupDiagrams < ActiveRecord::Migration[8.0]
  def change
    change_column :matchup_diagrams, :win_rate, :decimal, precision: 5, scale: 3, null: false
  end
end
