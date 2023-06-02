# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if user.admin?

    user.available_repositories
  end

  def update?
    user.id == record.company.user_id
  end

  alias_rule :destroy?, to: :update?
end
