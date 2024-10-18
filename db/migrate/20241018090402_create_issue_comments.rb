class CreateIssueComments < ActiveRecord::Migration[7.2]
  def change
    create_table :issue_comments, comment: 'Comments of issue' do |t|
      t.uuid :uuid, null: false
      t.bigint :issue_id, null: false
      t.string :external_id, null: false
      t.datetime :comment_created_at, comment: 'Time of creating comment in issue'
      t.timestamps
    end
    add_index :issue_comments, :uuid, unique: true
    add_index :issue_comments, :issue_id
  end
end
