class AddTypeIndexToNotifications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_index :notifications, :webhook_id
    add_index :notifications, [:webhook_id, :notification_type], unique: true, algorithm: :concurrently
    add_index :notifications, [:notifyable_id, :notifyable_type], algorithm: :concurrently
  end
end
