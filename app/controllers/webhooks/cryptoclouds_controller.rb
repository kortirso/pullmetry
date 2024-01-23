# frozen_string_literal: true

module Webhooks
  class CryptocloudsController < ApplicationController
    include Deps[
      add_service: 'services.persisters.subscriptions.add',
      jwt_encoder: 'jwt_encoder'
    ]

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate
    before_action :validate_status
    before_action :find_user
    before_action :find_invoice_payload

    def create
      if @invoice_payload['id'] == params[:invoice_id]
        add_service.call(user: @user, trial: false, days_period: days_period, invoice_id: params[:invoice_id])
      end
      head :ok
    end

    private

    def validate_status
      return if params[:status] == 'success'

      head :ok
    end

    def find_user
      @user = User.find_by!(uuid: user_uuid)
    end

    def find_invoice_payload
      @invoice_payload = jwt_encoder.decode(token: params[:token], secret: token_secret)
      return if @invoice_payload.present?

      head :ok
    end

    def user_uuid
      order_id_payload['uuid']
    end

    def days_period
      order_id_payload['days_period']
    end

    def order_id_payload
      @order_id_payload ||= jwt_encoder.decode(token: params[:order_id])
    end

    def token_secret
      Rails.application.credentials.secret_cryptoclouds
    end
  end
end
