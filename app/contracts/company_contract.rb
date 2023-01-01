# frozen_string_literal: true

class CompanyContract < ApplicationContract
  config.messages.namespace = :company

  params do
    required(:title).filled(:string)
    required(:name).filled(:string)
  end
end
