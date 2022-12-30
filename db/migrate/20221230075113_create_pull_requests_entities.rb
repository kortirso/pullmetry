class CreatePullRequestsEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :pull_requests_entities do |t|
      t.bigint :pull_request_id, null: false
      t.bigint :entity_id, null: false
      t.integer :origin, null: false, default: 0
      t.timestamps
    end
    add_index :pull_requests_entities, [:pull_request_id, :entity_id]
  end
end
