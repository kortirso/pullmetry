class ChangeUuidDefaultsKudos < ActiveRecord::Migration[7.2]
  TABLES = %i[
    kudos_achievements kudos_achievement_groups
  ]

  def change
    safety_assured do
      TABLES.each do |table|
        change_column_default table, :uuid, 'gen_random_uuid()'
      end
    end
  end
end
