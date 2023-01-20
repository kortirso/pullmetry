class AddHtmlUrlToEntities < ActiveRecord::Migration[7.0]
  def change
    add_column :entities, :html_url, :string
  end
end
