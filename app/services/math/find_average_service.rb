# frozen_string_literal: true

module Math
  class FindAverageService
    def call(values: [], type: nil)
      case type
      when :median then median(values)
      else arithmetic_mean(values)
      end
    end

    private

    def geometric_mean(values)
      return 0 if values.empty?

      values.inject(:*)**(1.0 / values.size)
    end

    def arithmetic_mean(values)
      return 0 if values.empty?

      values.sum / values.size
    end

    def median(values)
      return 0 if values.empty?

      midpoint = values.size / 2
      if values.length.even?
        arithmetic_mean(values.sort[midpoint - 1, 2])
      else
        values.sort[midpoint]
      end
    end
  end
end
