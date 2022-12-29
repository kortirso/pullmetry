class CreatePullRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :pull_requests do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :repository_id, null: false, index: true
      t.timestamps
    end
  end
end
