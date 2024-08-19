# frozen_string_literal: true

require 'openssl'
require 'base64'

module Authkeeper
  module Providers
    class Telegram
      REQUIRED_FIELDS = %i[id hash].freeze
      HASH_FIELDS = %i[auth_date first_name id last_name photo_url username].freeze
      SECONDS_IN_DAY = 86_400

      def call(params: {})
        return { errors: ['Required field is missing'] } unless required_fields_valid?(params)
        return { errors: ['Signature mismatch'] } unless signature_valid?(params)
        return { errors: ['Session expired'] } if session_expired?(params)

        {
          result: {
            uid: params[:id].to_s,
            provider: 'telegram',
            login: params[:username]
          }
        }
      end

      private

      def required_fields_valid?(params)
        REQUIRED_FIELDS.all? { |field| params.include?(field) }
      end

      def signature_valid?(params)
        params[:hash] == calculate_signature(params)
      end

      def session_expired?(params)
        Time.now.to_i - params[:auth_date].to_i > SECONDS_IN_DAY
      end

      def calculate_signature(params)
        secret = OpenSSL::Digest::SHA256.digest(omniauth_config[:bot_secret])
        signature = generate_comparison_string(params)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('SHA256'), secret, signature)
      end

      # rubocop: disable Style/FormatStringToken
      def generate_comparison_string(params)
        (params.keys & HASH_FIELDS).sort.map { |field| '%s=%s' % [field, params[field]] }.join("\n")
      end
      # rubocop: enable Style/FormatStringToken

      def omniauth_config
        @omniauth_config ||= Authkeeper.configuration.omniauth_configs[:telegram]
      end
    end
  end
end
