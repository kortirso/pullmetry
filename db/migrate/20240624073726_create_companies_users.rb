class CreateCompaniesUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :companies_users do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :company_id, null: false
      t.bigint :user_id, null: false
      t.bigint :invite_id, null: false
      t.integer :access, null: false, default: 0
      t.timestamps
    end
    add_index :companies_users, [:company_id, :user_id], unique: true
    add_index :companies_users, :invite_id
  end
end
