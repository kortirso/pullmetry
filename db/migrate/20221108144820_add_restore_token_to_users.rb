class AddRestoreTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :restore_token, :string
  end
end
