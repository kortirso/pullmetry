# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if user.admin?

    relation.where(id: user.available_repositories.select(:id))
  end

  def update?
    user.id == record.company.user_id
  end

  alias_rule :destroy?, to: :update?
end
