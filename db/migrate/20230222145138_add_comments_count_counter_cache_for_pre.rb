class AddCommentsCountCounterCacheForPre < ActiveRecord::Migration[7.0]
  def up
    add_column :pull_requests_entities, :pull_requests_comments_count, :integer, null: false, default: 0

    PullRequests::Entity.reset_column_information
    PullRequests::Entity.find_each do |pre|
      PullRequests::Entity.update_counters pre.id, pull_requests_comments_count: pre.pull_requests_comments.size
    end
  end

  def down
    remove_column :pull_requests_entities, :pull_requests_comments_count
  end
end
