# frozen_string_literal: true

module Math
  class FindAverage
    def call(values: [], type: nil, round_digits: 0)
      case type
      when :median then median(values, round_digits)
      when :geometric_mean then geometric_mean(values, round_digits)
      else arithmetic_mean(values, round_digits)
      end
    end

    private

    def geometric_mean(values, round_digits)
      return 0 if values.empty?

      result = values.inject(:*)**(1.0 / values.size)
      result.round(round_digits)
    end

    def arithmetic_mean(values, round_digits)
      return 0 if values.empty?

      result = values.sum.to_f / values.size
      result.round(round_digits)
    end

    def median(values, round_digits)
      return 0 if values.empty?

      midpoint = values.size / 2
      if values.length.even?
        arithmetic_mean(values.sort[midpoint - 1, 2], round_digits)
      else
        values.sort[midpoint]
      end
    end
  end
end
