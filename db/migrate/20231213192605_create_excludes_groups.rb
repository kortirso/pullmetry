class CreateExcludesGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :excludes_groups do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :insightable_id, null: false
      t.string :insightable_type, null: false
      t.timestamps
    end
    add_index :excludes_groups, [:insightable_id, :insightable_type]
  end
end
