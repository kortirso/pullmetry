class AddEntityIdToPullRequests < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :pull_requests, :entity_id, :bigint
    add_index :pull_requests, :entity_id, algorithm: :concurrently

    # PullRequests::Entity.where(origin: 'author').find_each do |pre|
    #   pre.pull_request.update(entity_id: pre.entity_id)
    # end

    safety_assured do
      remove_column :pull_requests_entities, :origin
      change_column_null :pull_requests, :entity_id, false
    end
  end
end
