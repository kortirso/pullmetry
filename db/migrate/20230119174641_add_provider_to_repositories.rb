class AddProviderToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :provider, :integer, null: false, default: 0
  end
end
