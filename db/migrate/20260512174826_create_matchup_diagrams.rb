class CreateMatchupDiagrams < ActiveRecord::Migration[8.0]
  def change
    create_table :matchup_diagrams do |t|
      t.string :rank, null: false
      t.string :character_code, null: false
      t.string :enemy_code, null: false
      t.decimal :win_rate, precision: 4, scale: 3, null: false
      t.string :season, null: false

      t.timestamps
    end

    add_index :matchup_diagrams, [ :character_code, :enemy_code, :rank ],
              unique: true, name: "index_matchup_diagrams_on_codes_and_rank"
  end
end
