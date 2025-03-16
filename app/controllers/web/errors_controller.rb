# frozen_string_literal: true

module Web
  class ErrorsController < ApplicationController
    skip_before_action :authenticate

    def internal; end

    def forbidden; end
  end
end
