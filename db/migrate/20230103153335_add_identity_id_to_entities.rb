class AddIdentityIdToEntities < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :entities, :identity_id, :bigint
    add_index :entities, :identity_id, algorithm: :concurrently
  end
end
