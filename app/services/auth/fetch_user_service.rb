# frozen_string_literal: true

module Auth
  class FetchUserService
    prepend ApplicationService

    attr_reader :session

    def call(token:)
      @payload = extract_uuid(token)
      @session = find_session

      fail!('Forbidden') if @payload.blank? || @session.blank?

      @result = @session&.user
    end

    private

    def extract_uuid(token)
      JwtEncoder.decode(token)
    end

    def find_session
      Users::Session.where(uuid: @payload.fetch('uuid', '')).first
    end
  end
end
