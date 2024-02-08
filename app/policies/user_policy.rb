# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create_repository?
    return false unless record.companies.exists?

    objects_count = record.repositories.size
    return objects_count < Subscription::PREMIUM_REPOSITORIES_AMOUNT if record.premium?

    objects_count < Subscription::FREE_REPOSITORIES_AMOUNT
  end
end
