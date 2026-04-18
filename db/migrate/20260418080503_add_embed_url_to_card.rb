class AddEmbedUrlToCard < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :embed_url, :string
  end
end
