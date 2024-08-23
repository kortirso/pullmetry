# frozen_string_literal: true

module PageWrappers
  class UserComponent < ApplicationViewComponent
    attr_reader :current_user

    def initialize(current_user:)
      @current_user = current_user

      super()
    end
  end
end
