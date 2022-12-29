# frozen_string_literal: true

module Auth
  class GenerateTokenService
    prepend ApplicationService

    def call(user:)
      ActiveRecord::Base.transaction do
        Users::Session.where(user: user).destroy_all
        @result = JwtEncoder.encode(uuid: Users::Session.create!(user: user).uuid)
      end
    end
  end
end
