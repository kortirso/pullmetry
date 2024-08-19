# frozen_string_literal: true

require 'authkeeper/version'
require 'authkeeper/engine'
require 'authkeeper/configuration'
require 'authkeeper/container'

require 'authkeeper/controllers/authentication'

module Authkeeper
  module_function

  # Public: Configure authkeeper.
  #
  #   Authkeeper.configure do |config|
  #     config.user_model = 'User'
  #     config.omniauth :github, client_id: 'id', client_secret: 'secret', redirect_url: 'redirect_url'
  #     config.omniauth :gitlab, client_id: 'id', client_secret: 'secret', redirect_url: 'redirect_url'
  #     config.omniauth :google, client_id: 'id', client_secret: 'secret', redirect_uri: 'redirect_uri'
  #     config.omniauth :telegram, client_id: 'id', client_secret: 'secret', bot_secret: 'bot_secret'
  #   end
  #
  def configure
    yield configuration

    configuration.validate
  end

  # Public: Returns Authkeeper::Configuration instance.
  def configuration
    return Authkeeper::Container.resolve(:configuration) if Authkeeper::Container.key?(:configuration)

    Authkeeper::Container.register(:configuration) { Configuration.new }
    Authkeeper::Container.resolve(:configuration)
  end
end
