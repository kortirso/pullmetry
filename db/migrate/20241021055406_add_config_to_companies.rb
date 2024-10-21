class AddConfigToCompanies < ActiveRecord::Migration[7.2]
  def up
    add_column :companies, :config, :jsonb, null: false, default: {}

    Company.find_each do |company|
      company.update!(config: company.configuration)
    end
  end

  def down
    remove_column :companies, :config
  end
end
