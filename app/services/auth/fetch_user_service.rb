# frozen_string_literal: true

module Auth
  class FetchUserService
    prepend ApplicationService

    def call(token:)
      @payload = extract_uuid(token)

      fail!('Forbidden') if @payload.blank? || session.blank?

      @result = session&.user
    end

    private

    def extract_uuid(token)
      JwtEncoder.decode(token)
    rescue JWT::DecodeError
      {}
    end

    def session
      @session ||= Users::Session.where(uuid: @payload.fetch('uuid', '')).first
    end
  end
end
