class AddAverageOpenPrCommentsToInsights < ActiveRecord::Migration[7.0]
  def change
    add_column :insights, :average_open_pr_comments, :decimal, precision: 6, scale: 2
    add_column :insights, :average_open_pr_comments_ratio, :integer
  end
end
