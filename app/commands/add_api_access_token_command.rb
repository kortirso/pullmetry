# frozen_string_literal: true

class AddApiAccessTokenCommand < BaseCommand
  use_contract do
    params do
      required(:user).filled(type?: User)
    end
  end

  private

  def do_persist(input)
    api_access_token = ApiAccessToken.create!(input.merge(value: SecureRandom.hex))

    { result: api_access_token }
  end
end
