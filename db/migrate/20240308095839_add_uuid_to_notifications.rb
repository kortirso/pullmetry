class AddUuidToNotifications < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      add_column :notifications, :uuid, :uuid
      add_index :notifications, :uuid

      Notification.find_each { |notification| notification.update(uuid: SecureRandom.uuid) }

      change_column_null :notifications, :uuid, false
    end
  end

  def down
    remove_column :notifications, :uuid
  end
end
