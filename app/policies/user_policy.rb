# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  authorize :amount, optional: true

  def create_repository?
    return false if !record.companies.exists? && amount.nil?
    return true if record.premium?

    objects_count = record.repositories.size + (amount || 1)
    objects_count <= User::Subscription::FREE_REPOSITORIES_AMOUNT
  end
end
