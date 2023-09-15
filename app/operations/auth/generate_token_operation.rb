# frozen_string_literal: true

module Auth
  class GenerateTokenOperation
    prepend ApplicationService

    def call(user:)
      @result = JwtEncoder.encode(uuid: Users::Session.create!(user: user).uuid)
    end
  end
end
