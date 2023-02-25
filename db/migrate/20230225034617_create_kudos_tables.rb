class CreateKudosTables < ActiveRecord::Migration[7.0]
  def self.up
    enable_extension 'pgcrypto' unless extensions.include?('pgcrypto')
    enable_extension 'uuid-ossp' unless extensions.include?('uuid-ossp')

    create_table :kudos_achievement_groups do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :parent_id, index: true
      t.integer :position, null: false, default: 0
      t.jsonb :name, null: false, default: {}
      t.timestamps
    end

    create_table :kudos_achievements do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.string :award_name, null: false, index: true
      t.integer :rank
      t.integer :points
      t.jsonb :title, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.references :kudos_achievement_group, null: false, index: true, foreign_key: true
      t.timestamps
    end

    create_table :kudos_users_achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :kudos_achievement, null: false, foreign_key: true
      t.boolean :notified, null: false, default: false
      t.integer :rank
      t.integer :points
      t.jsonb :title, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.timestamps
    end
    add_index :kudos_users_achievements, [:user_id, :kudos_achievement_id], unique: true, name: 'kudos_users_achievements_unique_index'
  end

  def self.down
    drop_table :kudos_achievement_groups
    drop_table :kudos_achievements
    drop_table :kudos_users_achievements
  end
end
