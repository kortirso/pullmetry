class AddAverageMergeSecondsToInsights < ActiveRecord::Migration[7.0]
  def up
    add_column :insights, :average_merge_seconds, :integer
    change_column_default :insights, :average_merge_seconds, 0
  end

  def down
    remove_column :insights, :average_merge_seconds
  end
end
