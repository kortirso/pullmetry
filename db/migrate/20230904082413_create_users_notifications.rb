class CreateUsersNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :users_notifications do |t|
      t.bigint :user_id, null: false, index: true
      t.boolean :value, null: false, default: false
      t.integer :notification_type, null: false, default: 0
      t.timestamps
    end
  end
end
