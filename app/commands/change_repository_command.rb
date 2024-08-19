# frozen_string_literal: true

class ChangeRepositoryCommand < BaseCommand
  use_contract do
    params do
      required(:repository).filled(type?: Repository)
      optional(:synced_at).filled(:date)
      optional(:pull_requests_count).filled(:integer)
      optional(:accessable).filled(:bool)
    end
  end

  private

  def do_persist(input)
    input[:repository].update!(input.except(:repository))

    { result: input[:repository].reload }
  end
end
