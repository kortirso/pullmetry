class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :tokenable_id, null: false
      t.string :tokenable_type, null: false
      t.string :value, null: false
      t.timestamps
    end
    add_index :access_tokens, [:tokenable_id, :tokenable_type], unique: true
  end
end
