class AddCompanyToWebhooks < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      add_column :webhooks, :company_id, :bigint
      add_index :webhooks, :company_id
      add_column :notifications, :webhook_id, :bigint
      add_index :notifications, :webhook_id

      Webhook.find_each do |webhook|
        webhook.update!(company_id: webhook.webhookable_id)
      end
      Notification.find_each do |notification|
        webhook = notification.notifyable.webhooks.where(source: notification.attributes['source']).first

        if webhook.present?
          notification.update!(webhook_id: webhook.id)
        end
      end
      Notification.where(webhook_id: nil).destroy_all

      change_column_null :webhooks, :company_id, false
      change_column_null :notifications, :webhook_id, false

      remove_column :webhooks, :webhookable_id
      remove_column :webhooks, :webhookable_type
      remove_column :notifications, :source
    end
  end
end
