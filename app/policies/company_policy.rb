# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if user.admin?

    relation.where(id: user.available_companies.select(:id))
  end

  def edit?
    user.id == record.user_id || record.companies_users.exists?(user_id: user.id)
  end

  # company's owner can update
  # user with write access can update
  def update?
    user.id == record.user_id || record.companies_users.write.exists?(user_id: user.id)
  end

  alias_rule :destroy?, to: :update?
end
