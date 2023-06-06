class AddAccessableToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :accessable, :boolean, null: false, default: true
  end
end
