# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  authorize :amount, optional: true

  # rubocop: disable Metrics/AbcSize
  def create_repository?
    return false if !record.companies.exists? && amount.nil?

    objects_count = record.repositories.size + (amount || 1)
    return objects_count <= User::Subscription::FREE_REPOSITORIES_AMOUNT unless record.premium?

    plan_settings = record.plan_settings
    return true if plan_settings[:repositories_limit].nil?

    objects_count <= plan_settings[:repositories_limit]
  end
  # rubocop: enable Metrics/AbcSize
end
