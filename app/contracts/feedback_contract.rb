# frozen_string_literal: true

class FeedbackContract < ApplicationContract
  config.messages.namespace = :feedback

  params do
    required(:description).filled(:string)
  end
end
