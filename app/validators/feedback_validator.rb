# frozen_string_literal: true

class FeedbackValidator < ApplicationValidator
  include Deps[contract: 'contracts.feedback']
end
