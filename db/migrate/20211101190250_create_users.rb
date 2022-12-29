class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.string :email, null: false, default: ''
      t.string :password_digest, null: false, default: ''
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
