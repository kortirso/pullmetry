class AddSettingsToCompaniesAndRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :configuration, :jsonb, null: false, default: {}
    safety_assured do
      remove_column :companies, :work_start_time, :datetime
      remove_column :companies, :work_end_time, :datetime
      remove_column :repositories, :start_from_pull_number, :integer
    end
  end
end
