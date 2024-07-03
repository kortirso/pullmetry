# frozen_string_literal: true

class ApiAccessToken < ApplicationRecord
  include Uuidable

  encrypts :value, deterministic: true

  belongs_to :user
end
