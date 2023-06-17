class ChangeSessionsIndexUniqueness < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    remove_index :users_sessions, column: :user_id
    add_index :users_sessions, :user_id, unique: false, algorithm: :concurrently
  end

  def down
    remove_index :users_sessions, column: :user_id
    add_index :users_sessions, :user_id, unique: true, algorithm: :concurrently
  end
end
