class AddWorkTimeZoneToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :work_time_zone, :string
  end
end
