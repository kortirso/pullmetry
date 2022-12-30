class CreatePullRequestsComments < ActiveRecord::Migration[7.0]
  def change
    create_table :pull_requests_comments do |t|
      t.bigint :pull_requests_entity_id, null: false, index: true
      t.string :external_id, null: false, index: true
      t.datetime :comment_created_at, null: false
      t.timestamps
    end
  end
end
