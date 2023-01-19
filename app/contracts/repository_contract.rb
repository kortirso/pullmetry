# frozen_string_literal: true

class RepositoryContract < ApplicationContract
  config.messages.namespace = :repository

  params do
    required(:title).filled(:string)
    required(:link).filled(:string)
    required(:provider).filled(:string)
    optional(:external_id)
  end

  rule(:provider, :external_id) do
    if values[:provider] == Providerable::GITLAB && values[:external_id].blank?
      key(:external_id).failure(:empty)
    end
  end
end
