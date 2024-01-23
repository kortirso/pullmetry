# frozen_string_literal: true

module Monitoring
  Warning = Class.new(StandardError)
  Info = Class.new(StandardError)

  class Client
    include Deps[provider: 'monitoring.providers.bugsnag']

    def notify(exception:, metadata: {}, severity: nil)
      provider.notify(exception: exception, metadata: metadata, severity: severity)
    end
  end
end
