class RemoveEnabledForNotifications < ActiveRecord::Migration[7.1]
  def up
    safety_assured { remove_column :notifications, :enabled }
  end

  def down
    add_column :notifications, :enabled, :boolean, default: true
  end
end
