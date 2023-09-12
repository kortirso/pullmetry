class AddCommentsCountCounterCacheForPullRequests < ActiveRecord::Migration[7.0]
  def up
    add_column :pull_requests, :pull_requests_comments_count, :integer, null: false, default: 0

    PullRequest.reset_column_information
    PullRequest.find_each do |pull_request|
      PullRequest.update_counters pull_request.id, pull_requests_comments_count: pull_request.pull_requests_comments.size
    end
  end

  def down
    remove_column :pull_requests, :pull_requests_comments_count
  end
end
