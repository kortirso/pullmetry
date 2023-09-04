class AddNotAccessableTicksForCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :not_accessable_ticks, :integer, null: false, default: 0
  end
end
