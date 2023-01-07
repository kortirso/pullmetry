# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create_repository?
    record.premium? || record.repositories.size < Subscription::FREE_REPOSITORIES_AMOUNT
  end
end
