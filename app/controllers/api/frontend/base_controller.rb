# frozen_string_literal: true

module Api
  module Frontend
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      skip_before_action :find_invite

      private

      def authenticate
        return if current_user

        access_denied
      end

      def page_not_found
        render json: { errors: ['Not found'] }, status: :not_found
      end

      def access_denied
        render json: { errors: ['Unauthorized'] }, status: :unauthorized
      end
    end
  end
end
