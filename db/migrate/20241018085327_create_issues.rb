class CreateIssues < ActiveRecord::Migration[7.2]
  def change
    create_table :issues do |t|
      t.uuid :uuid, null: false
      t.bigint :repository_id, null: false
      t.datetime :opened_at
      t.datetime :closed_at
      t.integer :issue_number
      t.timestamps
    end
    add_index :issues, :uuid, unique: true
    add_index :issues, :repository_id
  end
end
