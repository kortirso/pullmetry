class AddWorktimeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :work_start_time, :time
    add_column :users, :work_end_time, :time
  end
end
