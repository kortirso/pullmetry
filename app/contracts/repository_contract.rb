# frozen_string_literal: true

class RepositoryContract < ApplicationContract
  config.messages.namespace = :repository

  params do
    required(:title).filled(:string)
    required(:link).filled(:string)
    required(:provider).filled(:string)
    optional(:external_id)
  end

  rule(:provider, :link) do
    unless values[:link].starts_with?(Repository::LINK_FORMAT_BY_PROVIDER[values[:provider]])
      key(:link).failure(:invalid_host)
    end
  end

  rule(:provider, :external_id) do
    if values[:provider] == Providerable::GITLAB && values[:external_id].blank?
      key(:external_id).failure(:empty)
    end
  end

  rule(:link) do
    if values[:link].ends_with?('.git')
      key(:link).failure(:invalid_git)
    end
  end
end
