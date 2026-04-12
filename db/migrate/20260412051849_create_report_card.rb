class CreateReportCard < ActiveRecord::Migration[8.0]
  def change
    create_table :report_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.string :reason
      t.timestamps
    end
  end
end
