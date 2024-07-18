class AddLastOperPrInsights < ActiveRecord::Migration[7.1]
  def change
    add_column :insights, :time_since_last_open_pull_seconds, :integer, default: 0, comment: 'Time since last open pull request'
  end
end
