# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create_repository?
    return false unless record.companies.exists?

    objects_count = record.repositories.size
    return objects_count < Subscription::FREE_REPOSITORIES_AMOUNT unless record.premium?

    plan_settings = record.plan_settings
    return true if plan_settings[:repositories_limit].nil?

    objects_count < plan_settings[:repositories_limit]
  end
end
