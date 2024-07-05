class AddSourceIndexToWebhooks < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_index :webhooks, :company_id
    add_index :webhooks, [:company_id, :source, :url], unique: true, algorithm: :concurrently
  end
end
