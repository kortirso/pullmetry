# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    skip_before_action :find_invite
    before_action :authorize_admin

    layout 'admin'

    private

    def authorize_admin
      return if current_user.admin?

      redirect_to forbidden_path
    end
  end
end
