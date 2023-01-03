# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  def update?
    user.id == record.company.user_id
  end

  alias_rule :destroy?, to: :update?
end
