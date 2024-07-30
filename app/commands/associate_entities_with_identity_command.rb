# frozen_string_literal: true

class AssociateEntitiesWithIdentityCommand < BaseCommand
  use_contract do
    params do
      required(:identity).filled(type?: Identity)
    end
  end

  private

  def do_persist(input)
    # commento: entities.identity_id
    Entity
      .where(identity_id: nil, provider: input[:identity].provider, login: input[:identity].login)
      .update_all(identity_id: input[:identity].id)

    { result: :ok }
  end
end
