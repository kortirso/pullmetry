# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if user.admin?

    relation.where(id: user.available_repositories.select(:id))
  end

  # company's owner can update
  # user with write access can update
  def update?
    user.id == record.company.user_id || record.company.companies_users.write.exists?(user_id: user.id)
  end

  alias_rule :destroy?, to: :update?
end
