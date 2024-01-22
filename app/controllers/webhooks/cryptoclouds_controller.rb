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
      # TODO: validate payment amount for calculating days_period
      # params = { amount_crypto: '', currency: '' }
      if @invoice_payload['id'] == params[:invoice_id]
        add_service.call(user: @user, trial: false, days_period: 30, invoice_id: params[:invoice_id])
      end
      head :ok
    end

    private

    def validate_status
      return if params[:status] == 'success'

      head :ok
    end

    def find_user
      @user = User.find_by!(uuid: params[:order_id])
    end

    def find_invoice_payload
      @invoice_payload = jwt_encoder.decode(token: params[:token], secret: token_secret)
      return if @invoice_payload.present?

      head :ok
    end

    def token_secret
      Rails.application.credentials.secret_cryptoclouds
    end
  end
end
