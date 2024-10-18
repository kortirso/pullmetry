class RemovePlanFromSubscriptions < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :subscriptions, :plan }
  end
end
