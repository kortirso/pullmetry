class AddReviewsCountToInsights < ActiveRecord::Migration[7.0]
  def up
    add_column :insights, :reviews_count, :integer
    change_column_default :insights, :reviews_count, 0
  end

  def down
    remove_column :insights, :reviews_count
  end
end
