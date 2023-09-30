# frozen_string_literal: true

class JwtEncoder
  HMAC_SECRET = Rails.application.secret_key_base
  EXPIRATION_SECONDS = 86_400

  def encode(payload)
    JWT.encode(modify_payload(payload), HMAC_SECRET)
  end

  def decode(token)
    JWT.decode(token, HMAC_SECRET).first
  rescue JWT::DecodeError
    {}
  end

  def modify_payload(payload)
    payload.merge!(
      exp: DateTime.now.to_i + EXPIRATION_SECONDS
    )
  end
end
