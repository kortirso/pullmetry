class AddRepositoryInsightsForIssues < ActiveRecord::Migration[7.2]
  def change
    add_column :repositories_insights, :open_issues_count, :integer, comment: 'Open issues', null: false, default: 0
    add_column :repositories_insights, :closed_issues_count, :integer, comment: 'Closed issues', null: false, default: 0
    add_column :repositories_insights, :average_issue_comment_time, :integer, comment: 'Average time until first comment in issue', null: false, default: 0
    add_column :repositories_insights, :average_issue_close_time, :integer, comment: 'Average time until closing issue', null: false, default: 0
  end
end
