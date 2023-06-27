class AddAbsoluteChangesToInsights < ActiveRecord::Migration[7.0]
  def change
    add_column :insights, :comments_count_change, :integer
    add_column :insights, :reviews_count_change, :integer
    add_column :insights, :required_reviews_count_change, :integer
    add_column :insights, :open_pull_requests_count_change, :integer
    add_column :insights, :average_review_seconds_change, :integer
    add_column :insights, :average_merge_seconds_change, :integer
    add_column :insights, :average_open_pr_comments_change, :integer

    add_column :insights, :review_involving, :integer
    add_column :insights, :review_involving_ratio, :integer
    add_column :insights, :review_involving_change, :integer
  end
end
