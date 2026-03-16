class AddCardCopyCount < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :copy_count, :integer, default: 0
  end
end
