class CreateIgnores < ActiveRecord::Migration[7.1]
  def change
    create_table :ignores do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :insightable_id, null: false
      t.string :insightable_type, null: false
      t.string :entity_value, null: false
      t.timestamps
    end
    add_index :ignores, [:insightable_id, :insightable_type, :entity_value], unique: true
  end
end
