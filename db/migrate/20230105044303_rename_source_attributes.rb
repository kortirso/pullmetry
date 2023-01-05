class RenameSourceAttributes < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_column :entities, :source, :provider }
  end
end
