# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    layout 'admin'

    private

    def authorize_admin
      return if Current.user.admin?

      redirect_to root_path
    end
  end
end
