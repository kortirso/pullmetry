class AddUuidsToTables < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  TABLES_WITH_MODELS = {
    work_times: WorkTime,
    vacations: User::Vacation,
    subscriptions: User::Subscription,
    subscribers: Subscriber,
    repositories_insights: Repositories::Insight,
    pull_requests_reviews: PullRequest::Review,
    pull_requests_comments: PullRequest::Comment,
    insights: Insight,
    identities: Identity,
    feedbacks: User::Feedback
  }

  def up
    TABLES_WITH_MODELS.each do |table, model|
      add_column table, :uuid, :uuid
      change_column_default table, :uuid, 'gen_random_uuid()'
      add_index table, :uuid, unique: true, algorithm: :concurrently

      model.unscoped.in_batches do |relation|
        relation.where(uuid: nil).update_all('uuid = gen_random_uuid()')
      end

      safety_assured { change_column_null table, :uuid, false }
    end
  end

  def down
    safety_assured do
      TABLES_WITH_MODELS.each_key do |table|
        remove_column table, :uuid
      end
    end
  end
end
