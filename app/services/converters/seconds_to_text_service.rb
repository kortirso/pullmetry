# frozen_string_literal: true

module Converters
  class SecondsToTextService
    SECONDS_IN_MINUTE = 60
    SECONDS_IN_HOUR = 3_600
    SECONDS_IN_DAY = 86_400
    MINUTES_IN_HOUR = 60
    HOURS_IN_DAY = 24

    def call(value:)
      return '-' unless value.to_i.positive?
      return '1m' if value < SECONDS_IN_MINUTE

      minutes = (value / SECONDS_IN_MINUTE) % MINUTES_IN_HOUR
      return "#{minutes}m" if value < SECONDS_IN_HOUR

      hours = (value / SECONDS_IN_HOUR) % HOURS_IN_DAY
      return "#{hours}h #{minutes}m" if value < SECONDS_IN_DAY

      "#{value / SECONDS_IN_DAY}d #{hours}h #{minutes}m"
    end
  end
end
