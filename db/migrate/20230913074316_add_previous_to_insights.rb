class AddPreviousToInsights < ActiveRecord::Migration[7.0]
  def change
    add_column :insights, :previous_date, :string
  end
end
