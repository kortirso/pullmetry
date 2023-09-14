class AddEntityIdToCommentsAndReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_requests_comments, :pull_request_id, :bigint, index: true
    add_column :pull_requests_comments, :entity_id, :bigint, index: true
    add_column :pull_requests_reviews, :pull_request_id, :bigint, index: true
    add_column :pull_requests_reviews, :entity_id, :bigint, index: true

    PullRequests::Comment.find_each do |comment|
      pre = PullRequests::Entity.find_by(id: comment.pull_requests_entity_id)

      comment.update_columns(pull_request_id: pre.pull_request_id, entity_id: pre.entity_id)
    end

    PullRequests::Review.find_each do |review|
      pre = PullRequests::Entity.find_by(id: review.pull_requests_entity_id)

      review.update_columns(pull_request_id: pre.pull_request_id, entity_id: pre.entity_id)
    end
  end
end
