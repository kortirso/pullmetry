class CreateEmailbutlerTables < ActiveRecord::Migration[7.0]
  def self.up
    enable_extension 'uuid-ossp' unless extensions.include?('uuid-ossp')

    create_table :emailbutler_messages do |t|
      t.uuid :uuid, null: false, default: ''
      t.string :mailer, null: false
      t.string :action, null: false
      t.jsonb :params, null: false, default: {}
      t.string :send_to, array: true
      t.integer :status, null: false, default: 0
      t.datetime :timestamp
      t.integer :lock_version
      t.timestamps
    end
    add_index :emailbutler_messages, :uuid, unique: true
  end

  def self.down
    drop_table :emailbutler_messages
  end
end
