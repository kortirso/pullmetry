# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if user.admin?

    relation.where(id: user.available_companies.select(:id))
  end

  def update?
    user.id == record.user_id
  end

  alias_rule :edit?, :destroy?, to: :update?
end
