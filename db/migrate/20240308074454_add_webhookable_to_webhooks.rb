class AddWebhookableToWebhooks < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :webhooks, :webhookable_id, :bigint
      add_column :webhooks, :webhookable_type, :string
      add_index :webhooks, [:webhookable_id, :webhookable_type, :source], unique: true, algorithm: :concurrently

      Webhook.find_each do |webhook|
        webhook.update(
          webhookable_id: webhook.insightable_id,
          webhookable_type: webhook.insightable_type
        )
      end

      change_column_null :webhooks, :webhookable_id, false
      change_column_null :webhooks, :webhookable_type, false

      remove_index :webhooks, [:insightable_id, :insightable_type, :url]
      remove_column :webhooks, :insightable_id
      remove_column :webhooks, :insightable_type
    end
  end

  def down
    safety_assured do
      add_column :webhooks, :insightable_id, :bigint
      add_column :webhooks, :insightable_type, :string
      add_index :webhooks, [:insightable_id, :insightable_type, :url], unique: true, algorithm: :concurrently

      Webhook.find_each do |webhook|
        webhook.update(
          insightable_id: webhook.webhookable_id,
          insightable_type: webhook.webhookable_type
        )
      end

      change_column_null :webhooks, :insightable_id, false
      change_column_null :webhooks, :insightable_type, false

      remove_index :webhooks, [:webhookable_id, :webhookable_type, :source]
      remove_column :webhooks, :webhookable_id
      remove_column :webhooks, :webhookable_type
    end
  end
end
