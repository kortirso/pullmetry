class AddEnabledToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :enabled, :boolean, default: true
  end
end
