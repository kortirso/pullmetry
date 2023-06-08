# frozen_string_literal: true

module Insights
  module AverageTime
    class BasisService
      SECONDS_IN_DAY = 86_400
      MINUTES_IN_HOUR = 60
      WEEKEND_DAYS_INDEXES = [0, 6].freeze

      def initialize(find_average_service: Math::FindAverageService.new)
        @find_average_service = find_average_service
      end

      private

      attr_reader :work_start_time, :work_end_time

      # working time can be based on company working time
      # or at user's
      def find_using_work_time(pull_request)
        user = pull_request.entity.identity&.user
        @work_start_time, @work_end_time =
          if user&.with_work_time? && !@insightable.configuration.ignore_users_work_time
            [user.work_start_time, user.work_end_time]
          else
            [@insightable.configuration.work_start_time, @insightable.configuration.work_end_time]
          end
      end

      # if time is less than beginning of work day - use beginning of work day
      # if time is more than ending of work day - use ending of work day
      def convert_time(value)
        value_minutes = (value.hour * MINUTES_IN_HOUR) + value.min

        if value_minutes < work_start_time_minutes
          value.change(hour: work_start_time.hour, min: work_start_time.min, sec: 0)
        elsif value_minutes > work_end_time_minutes
          value.change(hour: work_end_time.hour, min: work_end_time.min, sec: 0)
        else
          value
        end
      end

      # find seconds between 2 times
      # except working hours at weekends and vacation
      # except night not working hours between days
      def seconds_between_times(start_time, end_time, vacations=nil)
        converted_vacations = convert_vacations(start_time, vacations)
        days = ((end_time.end_of_day.to_i - start_time.to_i) / SECONDS_IN_DAY)

        full_time_seconds = end_time.to_i - start_time.to_i
        not_working_day_seconds = not_working_day_seconds(days, start_time, end_time, converted_vacations)

        full_time_seconds - not_working_day_seconds - (days * not_working_night_seconds)
      end

      def not_working_day_seconds(days, start_time, end_time, converted_vacations)
        result = 0
        (days + 1).times do |day_index|
          if not_working_day?(start_time + day_index.days, converted_vacations)
            result += reduced_time(start_time, end_time, day_index, days)
          end
        end
        result
      end

      def not_working_day?(current_day, converted_vacations)
        current_day.wday.in?(WEEKEND_DAYS_INDEXES) || current_day.strftime('%Y-%m-%d').in?(converted_vacations)
      end

      def reduced_time(start_time, end_time, day_index, days_amount)
        return convert_day(work_end_time, start_time) - start_time.to_i if day_index.zero?
        return end_time.to_i - convert_day(work_start_time, end_time) if day_index == days_amount

        working_seconds
      end

      def convert_day(time, day_from)
        time.change(year: day_from.year, month: day_from.month, day: day_from.day).to_i
      end

      def convert_vacations(end_time, vacations)
        return [] if vacations.blank?

        vacations
          .where('start_time >= ?', end_time.beginning_of_day)
          .flat_map { |vacation|
            (vacation.start_time.to_datetime..vacation.end_time.to_datetime)
              .map { |date| date.strftime('%Y-%m-%d') }
              .uniq
          }
      end

      def update_result_with_total_review_time(entity_id, review_seconds)
        @result[entity_id] = @result.key?(entity_id) ? @result[entity_id].push(review_seconds) : [review_seconds]
      end

      def update_result_with_average_time
        @result.transform_values! do |value|
          @find_average_service.call(values: value, type: @insightable.configuration.average_type)
        end
      end

      def work_start_time_minutes
        (work_start_time.hour * MINUTES_IN_HOUR) + work_start_time.min
      end

      def work_end_time_minutes
        (work_end_time.hour * MINUTES_IN_HOUR) + work_end_time.min
      end

      # seconds between ending time previous day and starting time of new day in seconds
      def not_working_night_seconds
        work_start_time.to_i - (work_end_time - 1.day).to_i
      end

      def working_seconds
        SECONDS_IN_DAY - not_working_night_seconds
      end
    end
  end
end
