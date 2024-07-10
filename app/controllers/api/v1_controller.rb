# frozen_string_literal: true

module Api
  class V1Controller < ApplicationController
    protect_from_forgery with: :null_session

    skip_before_action :find_invite

    private

    def set_current_user
      return unless params[:api_access_token]

      api_access_token = ApiAccessToken.find_by(value: params[:api_access_token])
      return unless api_access_token

      Current.user ||= api_access_token.user
    end

    def serializer_fields(serializer_class, default_include_fields=[], forbidden_fields=[])
      @serializer_attributes = serializer_class::ATTRIBUTES
      return {} if response_only_fields.any? && response_except_fields.any?
      return { only: (response_only_fields - forbidden_fields).map(&:to_sym) } if response_only_fields.any?
      return { except: (response_except_fields + forbidden_fields).map(&:to_sym) } if response_except_fields.any?

      { only: default_include_fields.map(&:to_sym) }
    end

    def response_only_fields
      @response_only_fields ||= params[:response_only_fields]&.split(',').to_a & @serializer_attributes
    end

    def response_except_fields
      @response_except_fields ||= params[:response_except_fields]&.split(',').to_a & @serializer_attributes
    end

    def authentication_error
      render json: { errors: ['Unauthorized'] }, status: :unauthorized
    end

    def page_not_found
      render json: { errors: ['Not found'] }, status: :not_found
    end

    def access_denied
      render json: { errors: ['Unauthorized'] }, status: :unauthorized
    end
  end
end
