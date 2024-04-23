class AddBadReviewsCountToInsights < ActiveRecord::Migration[7.1]
  def change
    add_column :insights, :bad_reviews_count, :integer, null: false, default: 0
  end
end
