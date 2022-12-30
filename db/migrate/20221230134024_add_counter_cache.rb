class AddCounterCache < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :repositories_count, :integer
    add_column :repositories, :pull_requests_count, :integer
  end
end
