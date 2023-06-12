class AddAccessableToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :accessable, :boolean, null: false, default: true
  end
end
