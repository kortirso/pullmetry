# frozen_string_literal: true

class InviteValidator < ApplicationValidator
  include Deps[contract: 'contracts.invite']
end
