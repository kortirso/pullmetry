class AddConventionalCommentsCountToInsights < ActiveRecord::Migration[7.1]
  def change
    add_column :insights, :conventional_comments_count, :integer, default: 0
    add_column :repositories_insights, :conventional_comments_count, :integer, default: 0
  end
end
