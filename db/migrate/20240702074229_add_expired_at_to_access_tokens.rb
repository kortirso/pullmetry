class AddExpiredAtToAccessTokens < ActiveRecord::Migration[7.1]
  def change
    add_column :access_tokens, :expired_at, :datetime
  end
end
