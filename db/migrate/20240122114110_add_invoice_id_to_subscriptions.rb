class AddInvoiceIdToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :external_invoice_id, :string, comment: 'Invoice ID from external system'
  end
end
