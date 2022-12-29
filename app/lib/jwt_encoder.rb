# frozen_string_literal: true

module JwtEncoder
  module_function

  HMAC_SECRET = Rails.application.secret_key_base

  def encode(payload)
    JWT.encode(payload, HMAC_SECRET)
  end

  def decode(token)
    JWT.decode(token, HMAC_SECRET).first
  end
end
