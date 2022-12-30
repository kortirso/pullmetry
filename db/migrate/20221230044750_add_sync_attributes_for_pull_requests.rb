class AddSyncAttributesForPullRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_requests, :pull_number, :integer, null: false, index: true
    add_column :pull_requests, :pull_created_at, :datetime, null: false
    add_column :pull_requests, :pull_closed_at, :datetime
    add_column :pull_requests, :pull_merged_at, :datetime
    add_column :pull_requests, :open, :boolean, null: false, default: true
  end
end
