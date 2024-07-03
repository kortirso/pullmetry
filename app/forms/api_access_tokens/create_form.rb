# frozen_string_literal: true

module ApiAccessTokens
  class CreateForm
    def call(user:)
      { result: user.api_access_tokens.create!(value: SecureRandom.hex) }
    end
  end
end
