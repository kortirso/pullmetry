class CreateApiAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :api_access_tokens do |t|
      t.bigint :user_id, null: false, index: true
      t.text :value, null: false, index: true
      t.timestamps
    end
  end
end
