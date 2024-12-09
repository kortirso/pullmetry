# frozen_string_literal: true

module Authkeeper
  class GenerateTokenService
    include AuthkeeperDeps[jwt_encoder: 'jwt_encoder']

    def call(user_session:)
      {
        result: jwt_encoder.encode(
          payload: {
            uuid: user_session.id
          }
        )
      }
    end
  end
end
