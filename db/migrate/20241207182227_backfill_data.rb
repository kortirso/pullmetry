class BackfillData < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    User::Vacation.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    User::Session.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    User::Subscription.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    User::Feedback.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    ApiAccessToken.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    Company.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    Webhook.find_each do |item|
      item.update!(company_id: Company.find_by(numeric_id: item.numeric_company_id).id)
    end

    Notification.find_each do |item|
      item.update!(
        notifyable_id: item.notifyable_type.constantize.find_by(numeric_id: item.numeric_notifyable_id).id,
        webhook_id: Webhook.find_by(numeric_id: item.numeric_webhook_id).id
      )
    end

    WorkTime.find_each do |item|
      item.update!(
        worktimeable_id: item.worktimeable_type.constantize.find_by(numeric_id: item.numeric_worktimeable_id).id
      )
    end

    Invite.find_each do |item|
      item.update!(
        inviteable_id: item.inviteable_type.constantize.find_by(numeric_id: item.numeric_inviteable_id).id,
        receiver_id: User.find_by(numeric_id: item.numeric_receiver_id)&.id
      )
    end

    Companies::User.find_each do |item|
      item.update!(
        company_id: Company.find_by(numeric_id: item.numeric_company_id).id,
        user_id: User.find_by(numeric_id: item.numeric_user_id).id,
        invite_id: Invite.find_by(numeric_id: item.numeric_invite_id).id
      )
    end

    Repository.find_each do |item|
      item.update!(company_id: Company.find_by(numeric_id: item.numeric_company_id).id)
    end

    AccessToken.find_each do |item|
      item.update!(
        tokenable_id: item.tokenable_type.constantize.find_by(numeric_id: item.numeric_tokenable_id).id
      )
    end

    Identity.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    Entity.find_each do |item|
      item.update!(identity_id: User.find_by(numeric_id: item.numeric_identity_id)&.id)
    end

    Insight.find_each do |item|
      insightable = item.insightable_type.constantize.find_by(numeric_id: item.numeric_insightable_id)
      next if insightable.nil?

      item.update!(
        insightable_id: insightable.id,
        entity_id: Entity.find_by(numeric_id: item.numeric_entity_id).id
      )
    end

    Entity::Ignore.find_each do |item|
      item.update!(
        insightable_id: item.insightable_type.constantize.find_by(numeric_id: item.numeric_insightable_id).id
      )
    end

    Excludes::Group.find_each do |item|
      item.update!(
        insightable_id: item.insightable_type.constantize.find_by(numeric_id: item.numeric_insightable_id).id
      )
    end

    Excludes::Rule.find_each do |item|
      item.update!(excludes_group_id: Excludes::Group.find_by(numeric_id: item.numeric_excludes_group_id).id)
    end

    Issue.find_each do |item|
      item.update!(repository_id: Repository.find_by(numeric_id: item.numeric_repository_id).id)
    end

    Issue::Comment.find_each do |item|
      item.update!(issue_id: Issue.find_by(numeric_id: item.numeric_issue_id).id)
    end

    Repositories::Insight.find_each do |item|
      item.update!(repository_id: Repository.find_by(numeric_id: item.numeric_repository_id).id)
    end

    PullRequest.find_each do |item|
      item.update!(
        repository_id: Repository.find_by(numeric_id: item.numeric_repository_id).id,
        entity_id: Entity.find_by(numeric_id: item.numeric_entity_id).id
      )
    end

    PullRequest::Comment.find_each do |item|
      item.update!(
        pull_request_id: PullRequest.find_by(numeric_id: item.numeric_pull_request_id).id,
        entity_id: Entity.find_by(numeric_id: item.numeric_entity_id).id
      )
    end

    PullRequest::Review.find_each do |item|
      item.update!(
        pull_request_id: PullRequest.find_by(numeric_id: item.numeric_pull_request_id).id,
        entity_id: Entity.find_by(numeric_id: item.numeric_entity_id).id
      )
    end

    Kudos::Users::Achievement.find_each do |item|
      item.update!(user_id: User.find_by(numeric_id: item.numeric_user_id).id)
    end

    Insight.where(insightable_id: nil).destroy_all

    safety_assured do
      change_column_null :vacations, :user_id, false
      change_column_null :users_sessions, :user_id, false
      change_column_null :subscriptions, :user_id, false
      change_column_null :feedbacks, :user_id, false
      change_column_null :api_access_tokens, :user_id, false
      change_column_null :companies, :user_id, false
      change_column_null :companies_users, :company_id, false
      change_column_null :companies_users, :user_id, false
      change_column_null :companies_users, :invite_id, false
      change_column_null :webhooks, :company_id, false
      change_column_null :notifications, :notifyable_id, false
      change_column_null :notifications, :webhook_id, false
      change_column_null :work_times, :worktimeable_id, false
      change_column_null :invites, :inviteable_id, false
      change_column_null :repositories, :company_id, false
      change_column_null :access_tokens, :tokenable_id, false
      change_column_null :identities, :user_id, false
      change_column_null :insights, :insightable_id, false
      change_column_null :insights, :entity_id, false
      change_column_null :ignores, :insightable_id, false
      change_column_null :excludes_groups, :insightable_id, false
      change_column_null :excludes_rules, :excludes_group_id, false
      change_column_null :issues, :repository_id, false
      change_column_null :issue_comments, :issue_id, false
      change_column_null :repositories_insights, :repository_id, false
      change_column_null :pull_requests, :repository_id, false
      change_column_null :pull_requests, :entity_id, false
      change_column_null :pull_requests_comments, :pull_request_id, false
      change_column_null :pull_requests_comments, :entity_id, false
      change_column_null :pull_requests_reviews, :pull_request_id, false
      change_column_null :pull_requests_reviews, :entity_id, false
      change_column_null :kudos_users_achievements, :user_id, false

      change_column_null :vacations, :numeric_user_id, true
      change_column_null :users_sessions, :numeric_user_id, true
      change_column_null :subscriptions, :numeric_user_id, true
      change_column_null :feedbacks, :numeric_user_id, true
      change_column_null :api_access_tokens, :numeric_user_id, true
      change_column_null :companies, :numeric_user_id, true
      change_column_null :companies_users, :numeric_company_id, true
      change_column_null :companies_users, :numeric_user_id, true
      change_column_null :companies_users, :numeric_invite_id, true
      change_column_null :webhooks, :numeric_company_id, true
      change_column_null :notifications, :numeric_notifyable_id, true
      change_column_null :notifications, :numeric_webhook_id, true
      change_column_null :work_times, :numeric_worktimeable_id, true
      change_column_null :invites, :numeric_inviteable_id, true
      change_column_null :repositories, :numeric_company_id, true
      change_column_null :access_tokens, :numeric_tokenable_id, true
      change_column_null :identities, :numeric_user_id, true
      change_column_null :insights, :numeric_insightable_id, true
      change_column_null :insights, :numeric_entity_id, true
      change_column_null :ignores, :numeric_insightable_id, true
      change_column_null :excludes_groups, :numeric_insightable_id, true
      change_column_null :excludes_rules, :numeric_excludes_group_id, true
      change_column_null :issues, :numeric_repository_id, true
      change_column_null :issue_comments, :numeric_issue_id, true
      change_column_null :repositories_insights, :numeric_repository_id, true
      change_column_null :pull_requests, :numeric_repository_id, true
      change_column_null :pull_requests, :numeric_entity_id, true
      change_column_null :pull_requests_comments, :numeric_pull_request_id, true
      change_column_null :pull_requests_comments, :numeric_entity_id, true
      change_column_null :pull_requests_reviews, :numeric_pull_request_id, true
      change_column_null :pull_requests_reviews, :numeric_entity_id, true
      change_column_null :kudos_users_achievements, :numeric_user_id, true
    end

    Company.find_each do |company|
      Company.reset_counters company.id, :repositories_count
    end
  end

  def down; end
end
