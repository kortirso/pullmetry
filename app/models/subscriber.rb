# frozen_string_literal: true

class Subscriber < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_token :unsubscribe_token, length: 24
end
