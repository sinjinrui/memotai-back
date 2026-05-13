class AddRankToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :rank, :string
  end
end
