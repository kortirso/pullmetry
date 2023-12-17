class CreateExcludesRules < ActiveRecord::Migration[7.1]
  def change
    create_table :excludes_rules do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :excludes_group_id, null: false, index: true
      t.integer :target, null: false, comment: 'Target for comparison: branch name'
      t.integer :condition, null: false, comment: 'Condition for exclude rule: include/contain'
      t.string :value, null: false, comment: 'Value for comparison'
      t.timestamps
    end
  end
end
