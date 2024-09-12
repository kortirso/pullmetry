# frozen_string_literal: true

module Authkeeper
  class Configuration
    InitializeError = Class.new(StandardError)

    attr_accessor :user_model, :user_session_model, :access_token_name, :omniauth_providers
    attr_reader :omniauth_configs

    def initialize
      @user_model = 'User'
      @user_session_model = 'User::Session'

      @access_token_name = nil

      @omniauth_providers = []
      @omniauth_configs = {}
    end

    def validate
      validate_user_model
    end

    def omniauth(provider, **args)
      @omniauth_configs[provider] = args
    end

    private

    def validate_user_model
      raise InitializeError, 'User model must be present' if user_model.nil?
    end
  end
end
