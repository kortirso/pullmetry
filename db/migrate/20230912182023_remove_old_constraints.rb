class RemoveOldConstraints < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_index :pull_requests_comments, :pull_requests_entity_id
      remove_index :pull_requests_reviews, :pull_requests_entity_id

      change_column_null :pull_requests_comments, :pull_requests_entity_id, true
      change_column_null :pull_requests_reviews, :pull_requests_entity_id, true
      change_column_null :pull_requests_reviews, :external_id, true
      change_column_null :pull_requests_reviews, :review_created_at, true

      change_column_null :pull_requests_comments, :pull_request_id, false
      change_column_null :pull_requests_comments, :entity_id, false
      change_column_null :pull_requests_reviews, :pull_request_id, false
      change_column_null :pull_requests_reviews, :entity_id, false
    end
  end
end
