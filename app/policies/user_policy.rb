# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create_repository?
    return false unless record.companies.exists?
    return true if record.premium?

    record.repositories.size < Subscription::FREE_REPOSITORIES_AMOUNT
  end
end
