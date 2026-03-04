class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.text :text, null: false
      t.references :user, null: false, foreign_key: true

      t.string :character_code, null: false
      t.string :enemy_code, null: false

      t.integer :position, null: false, default: 0

      t.datetime :archived_at

      t.timestamps
    end

    add_index :cards, [:user_id, :character_code, :enemy_code, :position]
  end
end
