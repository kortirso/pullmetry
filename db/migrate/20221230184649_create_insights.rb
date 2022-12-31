class CreateInsights < ActiveRecord::Migration[7.0]
  def change
    create_table :insights do |t|
      t.bigint :insightable_id, null: false
      t.string :insightable_type, null: false
      t.bigint :entity_id, null: false, index: true
      t.integer :comments_count, null: false, default: 0
      t.timestamps
    end
    add_index :insights, [:insightable_id, :insightable_type]
  end
end
