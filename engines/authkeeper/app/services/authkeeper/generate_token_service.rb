# frozen_string_literal: true

module Authkeeper
  class GenerateTokenService
    include AuthkeeperDeps[jwt_encoder: 'jwt_encoder']

    def call(users_session:)
      {
        result: jwt_encoder.encode(
          payload: {
            uuid: users_session.uuid
          }
        )
      }
    end
  end
end
