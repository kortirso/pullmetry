# frozen_string_literal: true

module Authkeeper
  class FetchSessionService
    include AuthkeeperDeps[jwt_encoder: 'jwt_encoder']

    def call(token:)
      payload = extract_uuid(token)
      return { errors: ['Forbidden'] } if payload.blank?

      session = find_session(payload)
      return { errors: ['Forbidden'] } if session.blank?

      { result: session }
    end

    private

    def extract_uuid(token)
      jwt_encoder.decode(token: token)
    end

    def find_session(payload)
      Authkeeper
        .configuration.user_session_model.constantize
        .where(id: payload.fetch('uuid', '')).first
    end
  end
end
