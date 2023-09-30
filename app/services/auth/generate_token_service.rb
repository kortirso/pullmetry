# frozen_string_literal: true

module Auth
  class GenerateTokenService
    include Deps[jwt_encoder: 'jwt_encoder']

    def call(user:)
      { result: jwt_encoder.encode(uuid: Users::Session.create!(user: user).uuid) }
    end
  end
end
