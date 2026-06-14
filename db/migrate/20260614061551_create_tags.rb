class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :user
      t.timestamps
    end

    [ "コンボ", "立ち回り", "起き攻め", "クラシック", "モダン" ].each do |str|
      Tag.create!(name: str)
    end
  end
end
