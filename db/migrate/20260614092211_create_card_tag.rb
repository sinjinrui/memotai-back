class CreateCardTag < ActiveRecord::Migration[8.0]
  def change
    create_table :card_tags do |t|
      t.references :tag, foreign_key: true
      t.references :card, foreign_key: true
      t.timestamps
    end
  end
end
