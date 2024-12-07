# frozen_string_literal: true

class ApiAccessToken < ApplicationRecord
  encrypts :value, deterministic: true

  belongs_to :user
end
