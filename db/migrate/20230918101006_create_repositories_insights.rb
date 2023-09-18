class CreateRepositoriesInsights < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories_insights do |t|
      t.bigint :repository_id, null: false, index: true
      t.string :previous_date
      t.integer :open_pull_requests_count, null: false, default: 0
      t.integer :commented_pull_requests_count, null: false, default: 0
      t.integer :reviewed_pull_requests_count, null: false, default: 0
      t.integer :merged_pull_requests_count, null: false, default: 0
      t.integer :average_comment_time, null: false, default: 0
      t.integer :average_review_time, null: false, default: 0
      t.integer :average_merge_time, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.decimal :average_comments_count, precision: 6, scale: 2, null: false, default: 0.0
      t.integer :changed_loc, null: false, default: 0
      t.decimal :average_changed_loc, precision: 8, scale: 2, null: false, default: 0.0
      t.timestamps
    end
  end
end
