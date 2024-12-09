# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'
require 'sprockets/railtie'
require 'view_component'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pullmetry
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.middleware.use Rack::Deflater
    # Rack::Brotli goes directly under Rack::Deflater, if Rack::Deflater is present
    config.middleware.use Rack::Brotli

    I18n.available_locales = %i[en]
    config.i18n.default_locale = :en

    config.time_zone = 'UTC'

    config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :que

    config.autoload_paths << Rails.root.join('app/views/components')
    config.view_component.view_component_path = 'app/views/components'

    config.action_mailer.preview_paths << Rails.root.join('spec/mailers/previews')

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.generators do |g|
      g.test_framework :rspec, fixtures: true, views: false, view_specs: false, helper_specs: false,
                               routing_specs: false, controller_specs: true, request_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.stylesheets false
      g.javascripts false
      g.helper false

      g.orm :active_record, primary_key_type: :uuid
    end

    # allow encrypted and unencrypted data to co-exist
    config.active_record.encryption.support_unencrypted_data = true
    config.active_record.encryption.extend_queries = true

    config.yjit = false

    # Catch 404s
    config.after_initialize do |app|
      app.routes.append { match '*path', to: 'application#not_found', via: :all }
    end
  end
end
