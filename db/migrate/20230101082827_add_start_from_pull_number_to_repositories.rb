class AddStartFromPullNumberToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :start_from_pull_number, :integer
  end
end
