# frozen_string_literal: true

class RepositoryContract < ApplicationContract
  config.messages.namespace = :repository

  params do
    required(:title).filled(:string)
    required(:link).filled(:string)
  end
end
