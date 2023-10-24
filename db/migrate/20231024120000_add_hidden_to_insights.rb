class AddHiddenToInsights < ActiveRecord::Migration[7.0]
  def change
    add_column :insights, :hidden, :boolean, null: false, default: false, comment: 'Flag for hiding insights, if true - available only for owner'
  end
end
