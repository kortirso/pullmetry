# frozen_string_literal: true

class IdentityContract < ApplicationContract
  config.messages.namespace = :identity

  params do
    required(:uid).filled(:string)
    required(:provider).filled(:string)
    required(:email).filled(:string)
    optional(:login).filled(:string)
  end

  rule(:provider, :login) do
    if values[:provider] != Providerable::GOOGLE && values[:login].blank?
      key(:login).failure(:empty)
    end
  end
end
