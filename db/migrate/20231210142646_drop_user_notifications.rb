class DropUserNotifications < ActiveRecord::Migration[7.1]
  def change
    drop_table :users_notifications
  end
end
