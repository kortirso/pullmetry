class RemoveOpenAttributeFromPullRequests < ActiveRecord::Migration[7.0]
  def up
    safety_assured { remove_column :pull_requests, :open }
  end

  def down
    add_column :pull_requests, :open, :boolean, null: false, default: true
  end
end
