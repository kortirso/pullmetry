# frozen_string_literal: true

module Companies
  class UpdateContract < ApplicationContract
    config.messages.namespace = :company

    params do
      required(:title).filled(:string)
    end
  end
end
