class ChangeUuidDefaults < ActiveRecord::Migration[7.2]
  TABLES = %i[
    webhooks users_sessions users repositories pull_requests
    notifications issues issue_comments invites ignores excludes_rules
    excludes_groups entities companies_users companies api_access_tokens access_tokens
  ]

  def change
    safety_assured do
      TABLES.each do |table|
        change_column_default table, :uuid, 'gen_random_uuid()'
      end
    end
  end
end
