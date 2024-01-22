# frozen_string_literal: true

class JwtEncoder
  HMAC_SECRET = Rails.application.secret_key_base
  EXPIRATION_SECONDS = 604_800 # 1.week

  def encode(payload:, secret: HMAC_SECRET)
    JWT.encode(modify_payload(payload), secret)
  end

  def decode(token:, secret: HMAC_SECRET)
    JWT.decode(token, secret).first
  rescue JWT::DecodeError
    {}
  end

  def modify_payload(payload)
    payload.merge!(
      random: SecureRandom.hex,
      exp: DateTime.now.to_i + EXPIRATION_SECONDS
    )
  end
end
