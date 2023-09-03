# frozen_string_literal: true

require 'commento/adapters/active_record'

Commento.configure do |config|
  config.adapter = Commento::Adapters::ActiveRecord.new
  config.skip_table_names = %w[
    ar_internal_metadata
    schema_migrations
    event_store_events
    event_store_events_in_streams
    kudos_achievement_groups
    kudos_users_achievements
    kudos_achievements
    que_lockers
    que_values
    que_jobs
  ]
  config.skip_column_names = %w[
    id
    uuid
    created_at
    updated_at
  ]
end
