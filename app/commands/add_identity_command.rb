# frozen_string_literal: true

class AddIdentityCommand < BaseCommand
  include Deps[associate_entities_with_identity: 'commands.associate_entities_with_identity']

  use_contract do
    config.messages.namespace = :identity

    Providers = Dry::Types['strict.string'].enum(*Identity.providers.keys)

    params do
      required(:user).filled(type?: User)
      required(:uid).filled(:string)
      required(:provider).filled(Providers)
      required(:email).filled(:string)
      optional(:login).filled(:string)
    end

    rule(:provider, :login) do
      if values[:provider] != Providerable::GOOGLE && values[:login].blank?
        key(:login).failure(:empty)
      end
    end
  end

  private

  def do_persist(input)
    identity = ActiveRecord::Base.transaction do
      result = Identity.create!(input)
      associate_entities_with_identity.call({ identity: result }) if result.login.present?
      result
    end

    { result: identity }
  end
end
