# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def destroy?
    return user.id == record.inviteable.user_id if record.coworker?
    return user.id == record.inviteable_id if record.friend?

    false
  end
end
