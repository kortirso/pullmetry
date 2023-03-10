class AddInsightRatios < ActiveRecord::Migration[7.0]
  def change
    add_column :insights, :comments_count_ratio, :integer
    add_column :insights, :reviews_count_ratio, :integer
    add_column :insights, :required_reviews_count_ratio, :integer
    add_column :insights, :open_pull_requests_count_ratio, :integer
    add_column :insights, :average_review_seconds_ratio, :integer
    add_column :insights, :average_merge_seconds_ratio, :integer
  end
end
