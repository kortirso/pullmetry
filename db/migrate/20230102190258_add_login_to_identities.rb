class AddLoginToIdentities < ActiveRecord::Migration[7.0]
  def change
    add_column :identities, :login, :string
  end
end
