class AddRequiredToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_requests_reviews, :required, :boolean, null: false, default: false
  end
end
