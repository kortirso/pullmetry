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
      @serializer_attributes = serializer_class.attributes_to_serialize.keys.map(&:to_s)
      return {} if response_include_fields.any? && response_exclude_fields.any?
      return { include_fields: response_include_fields - forbidden_fields } if response_include_fields.any?
      return { exclude_fields: response_exclude_fields + forbidden_fields } if response_exclude_fields.any?

      { include_fields: default_include_fields }
    end

    def response_include_fields
      @response_include_fields ||= params[:response_include_fields]&.split(',').to_a & @serializer_attributes
    end

    def response_exclude_fields
      @response_exclude_fields ||= params[:response_exclude_fields]&.split(',').to_a & @serializer_attributes
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
