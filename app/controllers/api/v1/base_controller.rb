# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      skip_before_action :authenticate
      before_action :authenticate_api

      rescue_from ActionPolicy::Unauthorized, with: :access_denied

      private

      def authenticate_api
        return if current_user

        render json: { errors: 'error' }, status: :unauthorized
      end

      def access_denied
        render json: { errors: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
