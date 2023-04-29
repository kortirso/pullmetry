class RemoveRedundantIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :kudos_users_achievements, column: :user_id
  end
end
