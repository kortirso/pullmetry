class RemovePasswordsFromUsers < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :users, :password_digest
      remove_column :users, :confirmation_token
      remove_column :users, :confirmed_at
      remove_column :users, :restore_token
    end
  end
end
