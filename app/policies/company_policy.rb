# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def update?
    user.id == record.user_id
  end

  alias_rule :edit?, :destroy?, to: :update?
end
