class RemoveRatioFieldsForInsights < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :insights, :comments_count_ratio
      remove_column :insights, :reviews_count_ratio
      remove_column :insights, :required_reviews_count_ratio
      remove_column :insights, :open_pull_requests_count_ratio
      remove_column :insights, :average_review_seconds_ratio
      remove_column :insights, :average_merge_seconds_ratio
      remove_column :insights, :average_open_pr_comments_ratio
      remove_column :insights, :review_involving_ratio

      add_column :insights, :reviewed_loc, :integer
      add_column :insights, :average_reviewed_loc, :integer
      add_column :insights, :changed_loc, :integer
      add_column :insights, :average_changed_loc, :integer
    end
  end
end
