class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.bigint :notifyable_id, null: false
      t.string :notifyable_type, null: false
      t.integer :notification_type, null: false
      t.integer :source, null: false
      t.timestamps
    end
    add_index :notifications, [:notifyable_id, :notifyable_type, :notification_type, :source], unique: true
  end
end
