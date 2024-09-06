# frozen_string_literal: true

module Frontend
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session

    skip_before_action :find_invite

    private

    def authentication_error
      render json: { errors: ['Unauthorized'] }, status: :unauthorized # 401
    end

    def access_denied
      render json: { errors: ['Forbidden'] }, status: :forbidden # 403
    end

    def page_not_found
      render json: { errors: ['Not found'] }, status: :not_found # 404
    end
  end
end
