class CreateWorkTimes < ActiveRecord::Migration[7.2]
  def up
    create_table :work_times do |t|
      t.bigint :worktimeable_id, null: false
      t.string :worktimeable_type, null: false
      t.string :starts_at, null: false
      t.string :ends_at, null: false
      t.string :timezone, null: false, default: '0'
      t.timestamps
    end
    add_index :work_times, [:worktimeable_id, :worktimeable_type], unique: true

    User.find_each do |user|
      next if user.start_time.nil?
      next if user.end_time.nil?

      WorkTime.create!(
        worktimeable: user,
        starts_at: user.start_time,
        ends_at: user.end_time,
        timezone: user.time_zone
      )
    end

    Company.find_each do |company|
      configuration = company.configuration
      next if configuration.work_start_time.nil?
      next if configuration.work_end_time.nil?

      WorkTime.create!(
        worktimeable: company,
        starts_at: configuration.work_start_time.strftime('%H:%M'),
        ends_at: configuration.work_end_time.strftime('%H:%M'),
        timezone: configuration.work_time_zone ? (ActiveSupport::TimeZone[configuration.work_time_zone].utc_offset / 3_600) : '0'
      )
    end
  end

  def down
    remove_table :work_times
  end
end
