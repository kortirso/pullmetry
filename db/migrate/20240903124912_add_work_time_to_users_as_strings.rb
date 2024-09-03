class AddWorkTimeToUsersAsStrings < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :start_time, :string
    add_column :users, :end_time, :string
    add_column :users, :time_zone, :string

    User.find_each do |user|
      user.update!(
        start_time: user.work_start_time&.strftime('%H:%M'),
        end_time: user.work_end_time&.strftime('%H:%M'),
        time_zone: user.work_time_zone ? (ActiveSupport::TimeZone[user.work_time_zone].utc_offset / 3_600) : nil
      )
    end
  end

  def down
    remove_column :users, :start_time
    remove_column :users, :end_time
    remove_column :users, :time_zone
  end
end
