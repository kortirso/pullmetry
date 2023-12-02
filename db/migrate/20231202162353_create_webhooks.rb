class CreateWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :webhooks do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :insightable_id, null: false
      t.string :insightable_type, null: false
      t.integer :source, null: false, default: 0
      t.string :url, null: false
      t.timestamps
    end
    add_index :webhooks, [:insightable_id, :insightable_type, :url], unique: true
  end
end
