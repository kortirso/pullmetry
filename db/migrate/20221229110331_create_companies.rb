class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :user_id, null: false, index: true
      t.string :title, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
