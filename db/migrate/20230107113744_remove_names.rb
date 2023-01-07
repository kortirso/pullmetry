class RemoveNames < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :companies, :name, :string
      remove_column :repositories, :name, :string
    end
    add_column :repositories, :link, :string, null: false, default: ''
  end
end
