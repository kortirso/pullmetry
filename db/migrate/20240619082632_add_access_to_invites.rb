class AddAccessToInvites < ActiveRecord::Migration[7.1]
  def change
    add_column :invites, :access, :integer, null: false, default: 0
  end
end
