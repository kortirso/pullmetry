class AllowNilForCommentsCount < ActiveRecord::Migration[7.0]
  def change
    change_column_null :insights, :comments_count, true
  end
end
