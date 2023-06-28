class AddAbsoluteChangesToInsights < ActiveRecord::Migration[7.0]
  def change
    add_column :insights, :review_involving, :integer
    add_column :insights, :review_involving_ratio, :integer
  end
end
