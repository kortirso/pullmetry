# frozen_string_literal: true

class RemoveAccessTokenCommand < BaseCommand
  use_contract do
    config.messages.namespace = :access_token

    params do
      required(:access_token).filled(type?: AccessToken)
    end
  end

  private

  def do_persist(input)
    input[:access_token].destroy

    { result: :ok }
  end
end
