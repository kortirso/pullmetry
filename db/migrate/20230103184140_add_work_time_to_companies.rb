class AddWorkTimeToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :work_start_time, :time
    add_column :companies, :work_end_time, :time
  end
end
