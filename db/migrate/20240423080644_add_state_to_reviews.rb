class AddStateToReviews < ActiveRecord::Migration[7.1]
  def change
    add_column :pull_requests_reviews, :state, :integer, null: false, default: 0
    add_column :pull_requests_reviews, :commit_external_id, :string

    add_column :pull_requests, :last_commit_external_id, :string
  end
end
