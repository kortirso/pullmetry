class AddUuidToApiAccessTokens < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      add_column :api_access_tokens, :uuid, :uuid
      add_index :api_access_tokens, :uuid

      ApiAccessToken.find_each { |api_access_token| api_access_token.update(uuid: SecureRandom.uuid) }

      change_column_null :api_access_tokens, :uuid, false
    end
  end

  def down
    remove_column :api_access_tokens, :uuid
  end
end
