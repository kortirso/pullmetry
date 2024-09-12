# frozen_string_literal: true

module AuthContext
  class RemoveExpiredUserSessionsJob < ApplicationJob
    queue_as :default

    def perform
      User::Session
        .where(created_at: ...DateTime.now - JwtEncoder::EXPIRATION_SECONDS.seconds)
        .destroy_all
    end
  end
end
