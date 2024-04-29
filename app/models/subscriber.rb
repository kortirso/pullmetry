# frozen_string_literal: true

class Subscriber < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_token :unsubscribe_token, length: 24

  encrypts :email, deterministic: true
end
