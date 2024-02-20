class CreateSubscribers < ActiveRecord::Migration[7.1]
  def change
    create_table :subscribers do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :unsubscribe_token, null: false
      t.datetime :unsubscribed_at
      t.timestamps
    end
  end
end
