class CreateEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :entities do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.string :external_id, null: false
      t.integer :source, null: false, default: 0
      t.string :login
      t.string :avatar_url
      t.timestamps
    end
    add_index :entities, [:source, :external_id], unique: true
  end
end
