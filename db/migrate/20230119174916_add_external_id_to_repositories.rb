class AddExternalIdToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :external_id, :string
  end
end
