class AddFieldsToInsights < ActiveRecord::Migration[7.0]
  def up
    add_column :insights, :required_reviews_count, :integer
    change_column_default :insights, :required_reviews_count, 0
    add_column :insights, :open_pull_requests_count, :integer
    change_column_default :insights, :open_pull_requests_count, 0
    add_column :insights, :average_review_seconds, :integer
    change_column_default :insights, :average_review_seconds, 0
  end

  def down
    remove_column :insights, :required_reviews_count
    remove_column :insights, :open_pull_requests_count
    remove_column :insights, :average_review_seconds
  end
end
