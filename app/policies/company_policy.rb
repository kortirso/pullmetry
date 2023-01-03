# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def update?
    user.id == record.user_id
  end

  alias_rule :destroy?, to: :update?
end
