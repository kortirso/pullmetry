# frozen_string_literal: true

module Users
  class CompleteService
    prepend ApplicationService

    def call(user:)
      user.update!(
        confirmation_token: nil,
        confirmed_at: DateTime.now
      )
    end
  end
end
