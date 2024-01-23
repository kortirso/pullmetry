# frozen_string_literal: true

module Monitoring
  module Providers
    class Bugsnag
      def notify(exception:, metadata: {}, severity: nil)
        ::Bugsnag.notify(exception_message(exception, severity)) do |event|
          # Adjust the severity of this notification
          event.severity = severity if severity

          # Add customer information to this event
          event.add_metadata(:metadata, metadata)
        end
      end

      private

      def exception_message(exception, severity)
        return exception unless exception.is_a?(String)

        case severity
        when :warning then Monitoring::Warning.new(exception)
        when :info then Monitoring::Info.new(exception)
        else exception
        end
      end
    end
  end
end
