class ChangePrimaryKeys < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_foreign_key :kudos_users_achievements, column: :user_id

      rename_column :users, :id, :numeric_id
      rename_column :users, :uuid, :id
      change_pk(:users)
      change_column_null :users, :numeric_id, true

      # vacations
      rename_column :vacations, :id, :numeric_id
      rename_column :vacations, :uuid, :id
      change_pk(:vacations)
      change_column_null :vacations, :numeric_id, true

      rename_column :vacations, :user_id, :numeric_user_id
      add_column :vacations, :user_id, :uuid
      add_index :vacations, :user_id, algorithm: :concurrently

      # users_sessions
      rename_column :users_sessions, :id, :numeric_id
      rename_column :users_sessions, :uuid, :id
      change_pk(:users_sessions)
      change_column_null :users_sessions, :numeric_id, true

      rename_column :users_sessions, :user_id, :numeric_user_id
      add_column :users_sessions, :user_id, :uuid
      add_index :users_sessions, :user_id, algorithm: :concurrently

      # subscriptions
      rename_column :subscriptions, :id, :numeric_id
      rename_column :subscriptions, :uuid, :id
      change_pk(:subscriptions)
      change_column_null :subscriptions, :numeric_id, true

      rename_column :subscriptions, :user_id, :numeric_user_id
      add_column :subscriptions, :user_id, :uuid
      add_index :subscriptions, :user_id, algorithm: :concurrently

      # feedbacks
      rename_column :feedbacks, :id, :numeric_id
      rename_column :feedbacks, :uuid, :id
      change_pk(:feedbacks)
      change_column_null :feedbacks, :numeric_id, true

      rename_column :feedbacks, :user_id, :numeric_user_id
      add_column :feedbacks, :user_id, :uuid
      add_index :feedbacks, :user_id, algorithm: :concurrently

      # api_access_tokens
      rename_column :api_access_tokens, :id, :numeric_id
      rename_column :api_access_tokens, :uuid, :id
      change_pk(:api_access_tokens)
      change_column_null :api_access_tokens, :numeric_id, true

      rename_column :api_access_tokens, :user_id, :numeric_user_id
      add_column :api_access_tokens, :user_id, :uuid
      add_index :api_access_tokens, :user_id, algorithm: :concurrently

      # companies
      rename_column :companies, :id, :numeric_id
      rename_column :companies, :uuid, :id
      change_pk(:companies)
      change_column_null :companies, :numeric_id, true

      rename_column :companies, :user_id, :numeric_user_id
      add_column :companies, :user_id, :uuid
      add_index :companies, :user_id, algorithm: :concurrently

      # webhooks
      rename_column :webhooks, :id, :numeric_id
      rename_column :webhooks, :uuid, :id
      change_pk(:webhooks)
      change_column_null :webhooks, :numeric_id, true

      rename_column :webhooks, :company_id, :numeric_company_id
      add_column :webhooks, :company_id, :uuid
      add_index :webhooks, [:company_id, :source, :url], unique: true, algorithm: :concurrently

      # notifications
      rename_column :notifications, :id, :numeric_id
      rename_column :notifications, :uuid, :id
      change_pk(:notifications)
      change_column_null :notifications, :numeric_id, true

      rename_column :notifications, :notifyable_id, :numeric_notifyable_id
      add_column :notifications, :notifyable_id, :uuid
      rename_column :notifications, :webhook_id, :numeric_webhook_id
      add_column :notifications, :webhook_id, :uuid
      add_index :notifications, [:webhook_id, :notification_type], unique: true, algorithm: :concurrently
      add_index :notifications, [:notifyable_id, :notifyable_type], algorithm: :concurrently

      # work_times
      rename_column :work_times, :id, :numeric_id
      rename_column :work_times, :uuid, :id
      change_pk(:work_times)
      change_column_null :work_times, :numeric_id, true

      rename_column :work_times, :worktimeable_id, :numeric_worktimeable_id
      add_column :work_times, :worktimeable_id, :uuid
      add_index :work_times, [:worktimeable_id, :worktimeable_type], unique: true, algorithm: :concurrently

      # invites
      rename_column :invites, :id, :numeric_id
      rename_column :invites, :uuid, :id
      change_pk(:invites)
      change_column_null :invites, :numeric_id, true

      rename_column :invites, :inviteable_id, :numeric_inviteable_id
      add_column :invites, :inviteable_id, :uuid
      rename_column :invites, :receiver_id, :numeric_receiver_id
      add_column :invites, :receiver_id, :uuid
      add_index :invites, [:inviteable_id, :inviteable_type, :receiver_id], algorithm: :concurrently

      # companies_users
      rename_column :companies_users, :id, :numeric_id
      rename_column :companies_users, :uuid, :id
      change_pk(:companies_users)
      change_column_null :companies_users, :numeric_id, true

      rename_column :companies_users, :user_id, :numeric_user_id
      add_column :companies_users, :user_id, :uuid
      rename_column :companies_users, :company_id, :numeric_company_id
      add_column :companies_users, :company_id, :uuid
      rename_column :companies_users, :invite_id, :numeric_invite_id
      add_column :companies_users, :invite_id, :uuid
      add_index :companies_users, [:company_id, :user_id], unique: true, algorithm: :concurrently
      add_index :companies_users, :invite_id, algorithm: :concurrently

      # repositories
      rename_column :repositories, :id, :numeric_id
      rename_column :repositories, :uuid, :id
      change_pk(:repositories)
      change_column_null :repositories, :numeric_id, true

      rename_column :repositories, :company_id, :numeric_company_id
      add_column :repositories, :company_id, :uuid
      add_index :repositories, :company_id, algorithm: :concurrently

      # access_tokens
      rename_column :access_tokens, :id, :numeric_id
      rename_column :access_tokens, :uuid, :id
      change_pk(:access_tokens)
      change_column_null :access_tokens, :numeric_id, true

      rename_column :access_tokens, :tokenable_id, :numeric_tokenable_id
      add_column :access_tokens, :tokenable_id, :uuid
      add_index :access_tokens, [:tokenable_id, :tokenable_type], unique: true, algorithm: :concurrently

      # identities
      rename_column :identities, :id, :numeric_id
      rename_column :identities, :uuid, :id
      change_pk(:identities)
      change_column_null :identities, :numeric_id, true

      rename_column :identities, :user_id, :numeric_user_id
      add_column :identities, :user_id, :uuid
      add_index :identities, :user_id, algorithm: :concurrently

      # entities
      rename_column :entities, :id, :numeric_id
      rename_column :entities, :uuid, :id
      change_pk(:entities)
      change_column_null :entities, :numeric_id, true

      rename_column :entities, :identity_id, :numeric_identity_id
      add_column :entities, :identity_id, :uuid
      add_index :entities, :identity_id, algorithm: :concurrently

      # insights
      rename_column :insights, :id, :numeric_id
      rename_column :insights, :uuid, :id
      change_pk(:insights)
      change_column_null :insights, :numeric_id, true

      rename_column :insights, :insightable_id, :numeric_insightable_id
      add_column :insights, :insightable_id, :uuid
      rename_column :insights, :entity_id, :numeric_entity_id
      add_column :insights, :entity_id, :uuid
      add_index :insights, [:insightable_id, :insightable_type], algorithm: :concurrently
      add_index :insights, :entity_id, algorithm: :concurrently

      # subscribers
      rename_column :subscribers, :id, :numeric_id
      rename_column :subscribers, :uuid, :id
      change_pk(:subscribers)
      change_column_null :subscribers, :numeric_id, true

      # ignores
      rename_column :ignores, :id, :numeric_id
      rename_column :ignores, :uuid, :id
      change_pk(:ignores)
      change_column_null :ignores, :numeric_id, true

      rename_column :ignores, :insightable_id, :numeric_insightable_id
      add_column :ignores, :insightable_id, :uuid
      add_index :ignores, [:insightable_id, :insightable_type, :entity_value], unique: true, algorithm: :concurrently

      # excludes_groups
      rename_column :excludes_groups, :id, :numeric_id
      rename_column :excludes_groups, :uuid, :id
      change_pk(:excludes_groups)
      change_column_null :excludes_groups, :numeric_id, true

      rename_column :excludes_groups, :insightable_id, :numeric_insightable_id
      add_column :excludes_groups, :insightable_id, :uuid
      add_index :excludes_groups, [:insightable_id, :insightable_type], algorithm: :concurrently

      # excludes_rules
      rename_column :excludes_rules, :id, :numeric_id
      rename_column :excludes_rules, :uuid, :id
      change_pk(:excludes_rules)
      change_column_null :excludes_rules, :numeric_id, true

      rename_column :excludes_rules, :excludes_group_id, :numeric_excludes_group_id
      add_column :excludes_rules, :excludes_group_id, :uuid
      add_index :excludes_rules, :excludes_group_id

      # issues
      rename_column :issues, :id, :numeric_id
      rename_column :issues, :uuid, :id
      change_pk(:issues)
      change_column_null :issues, :numeric_id, true

      rename_column :issues, :repository_id, :numeric_repository_id
      add_column :issues, :repository_id, :uuid
      add_index :issues, :repository_id

      # issue_comments
      rename_column :issue_comments, :id, :numeric_id
      rename_column :issue_comments, :uuid, :id
      change_pk(:issue_comments)
      change_column_null :issue_comments, :numeric_id, true

      rename_column :issue_comments, :issue_id, :numeric_issue_id
      add_column :issue_comments, :issue_id, :uuid
      add_index :issue_comments, :issue_id

      # repositories_insights
      rename_column :repositories_insights, :id, :numeric_id
      rename_column :repositories_insights, :uuid, :id
      change_pk(:repositories_insights)
      change_column_null :repositories_insights, :numeric_id, true

      rename_column :repositories_insights, :repository_id, :numeric_repository_id
      add_column :repositories_insights, :repository_id, :uuid
      add_index :repositories_insights, :repository_id

      # pull_requests
      rename_column :pull_requests, :id, :numeric_id
      rename_column :pull_requests, :uuid, :id
      change_pk(:pull_requests)
      change_column_null :pull_requests, :numeric_id, true

      rename_column :pull_requests, :repository_id, :numeric_repository_id
      add_column :pull_requests, :repository_id, :uuid
      rename_column :pull_requests, :entity_id, :numeric_entity_id
      add_column :pull_requests, :entity_id, :uuid
      add_index :pull_requests, :repository_id
      add_index :pull_requests, :entity_id

      # pull_requests_comments
      rename_column :pull_requests_comments, :id, :numeric_id
      rename_column :pull_requests_comments, :uuid, :id
      change_pk(:pull_requests_comments)
      change_column_null :pull_requests_comments, :numeric_id, true

      rename_column :pull_requests_comments, :pull_request_id, :numeric_pull_request_id
      add_column :pull_requests_comments, :pull_request_id, :uuid
      rename_column :pull_requests_comments, :entity_id, :numeric_entity_id
      add_column :pull_requests_comments, :entity_id, :uuid
      add_index :pull_requests_comments, :pull_request_id
      add_index :pull_requests_comments, :entity_id

      # pull_requests_reviews
      rename_column :pull_requests_reviews, :id, :numeric_id
      rename_column :pull_requests_reviews, :uuid, :id
      change_pk(:pull_requests_reviews)
      change_column_null :pull_requests_reviews, :numeric_id, true

      rename_column :pull_requests_reviews, :pull_request_id, :numeric_pull_request_id
      add_column :pull_requests_reviews, :pull_request_id, :uuid
      rename_column :pull_requests_reviews, :entity_id, :numeric_entity_id
      add_column :pull_requests_reviews, :entity_id, :uuid
      add_index :pull_requests_reviews, :pull_request_id
      add_index :pull_requests_reviews, :entity_id

      # kudos_users_achievements
      rename_column :kudos_users_achievements, :user_id, :numeric_user_id
      add_column :kudos_users_achievements, :user_id, :uuid
      add_index :kudos_users_achievements, :user_id
    end
  end

  def down; end

  def change_pk(table)
    execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey;"
    execute "ALTER TABLE #{table} ADD PRIMARY KEY (id);"
    execute "ALTER TABLE ONLY #{table} ALTER COLUMN numeric_id DROP DEFAULT;"
    execute "DROP SEQUENCE IF EXISTS #{table}_id_seq"

    change_column_null table, :numeric_id, true
  end
end
