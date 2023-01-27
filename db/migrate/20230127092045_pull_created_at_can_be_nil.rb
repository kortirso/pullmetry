class PullCreatedAtCanBeNil < ActiveRecord::Migration[7.0]
  def change
    change_column_null :pull_requests, :pull_created_at, true
  end
end
