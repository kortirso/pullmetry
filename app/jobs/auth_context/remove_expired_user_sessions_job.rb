# frozen_string_literal: true

module AuthContext
  class RemoveExpiredUserSessionsJob < ApplicationJob
    queue_as :default

    def perform
      User::Session
        .destroy_by(created_at: ...DateTime.now - JwtEncoder::EXPIRATION_SECONDS.seconds)
    end
  end
end
