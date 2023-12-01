# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    layout 'admin'

    private

    def authorize_admin
      return if current_user.admin?

      authentication_error
    end
  end
end
