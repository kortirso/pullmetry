class CreateUsersSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :users_sessions do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :user_id, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
