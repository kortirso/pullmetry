class AddSyncedAtToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :synced_at, :datetime
  end
end
