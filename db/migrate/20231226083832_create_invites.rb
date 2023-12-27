class CreateInvites < ActiveRecord::Migration[7.1]
  def change
    create_table :invites do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :inviteable_id, null: false
      t.string :inviteable_type, null: false
      t.bigint :receiver_id
      t.string :email
      t.string :code
      t.timestamps
    end
    add_index :invites, [:inviteable_id, :inviteable_type, :receiver_id]
  end
end
