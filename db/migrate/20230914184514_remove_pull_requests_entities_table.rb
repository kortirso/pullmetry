class RemovePullRequestsEntitiesTable < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      drop_table :pull_requests_entities

      remove_column :pull_requests_comments, :pull_requests_entity_id
      remove_column :pull_requests_reviews, :pull_requests_entity_id
    end
  end
end
