# frozen_string_literal: true

module Companies
  class CreateContract < ApplicationContract
    config.messages.namespace = :company

    params do
      required(:title).filled(:string)
      required(:name).filled(:string)
    end
  end
end
