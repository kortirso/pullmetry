# frozen_string_literal: true

module Insights
  module AverageTime
    class BasisService
      include Deps[find_average: 'math.find_average']

      SECONDS_IN_DAY = 86_400
      MINUTES_IN_DAY = 1_440
      MINUTES_IN_HOUR = 60
      SECONDS_IN_MINUTE = 60
      WEEKEND_DAYS_INDEXES = [0, 6].freeze
      DEFAULT_WORK_TIME_ZONE = 'UTC'

      private

      attr_reader :work_start_time, :work_end_time

      # working time can be based on company working time
      # or at user's
      def find_using_work_time(pull_request)
        user = pull_request.entity.identity&.user
        @work_start_time, @work_end_time, @time_offset =
          if user&.with_work_time? && !@insightable.configuration.ignore_users_work_time
            user_work_time_params(user)
          else
            insightable_work_time_params
          end
      end

      def user_work_time_params(user)
        [
          user.work_start_time,
          user.work_end_time,
          ActiveSupport::TimeZone[user.work_time_zone || DEFAULT_WORK_TIME_ZONE].utc_offset
        ]
      end

      def insightable_work_time_params
        [
          @insightable.configuration.work_start_time,
          @insightable.configuration.work_end_time,
          ActiveSupport::TimeZone[@insightable.configuration.work_time_zone || DEFAULT_WORK_TIME_ZONE].utc_offset
        ]
      end

      # if time is less than beginning of work day - use beginning of work day
      # if time is more than ending of work day - use ending of work day
      def convert_time(value, for_start)
        value += @time_offset.seconds
        value_minutes = (value.hour * MINUTES_IN_HOUR) + value.min

        if work_start_time_minutes < work_end_time_minutes
          convert_time_for_day_mode(value, value_minutes)
        else
          convert_time_for_night_mode(value, value_minutes, for_start)
        end
      end

      def convert_time_for_day_mode(value, value_minutes)
        @night_mode = false
        # conditions for working at day time
        if value_minutes < work_start_time_minutes
          change_hours_for_time(value, work_start_time)
        elsif value_minutes > work_end_time_minutes
          change_hours_for_time(value, work_end_time)
        else
          value
        end
      end

      def convert_time_for_night_mode(value, value_minutes, for_start)
        @night_mode = true
        # conditions for working at night time
        if value_minutes < work_end_time_minutes || value_minutes > work_start_time_minutes
          value
        elsif for_start
          change_hours_for_time(value, work_start_time)
        else
          change_hours_for_time(value, work_end_time)
        end
      end

      def change_hours_for_time(value, from_value)
        value.change(hour: from_value.hour, min: from_value.min, sec: 0)
      end

      def change_date_for_time(value, from_value)
        value.change(year: from_value.year, month: from_value.month, day: from_value.day)
      end

      # find seconds between 2 times
      # except working hours at weekends and vacation
      # except not working hours between days
      def seconds_between_times(start_time, end_time, vacations=nil)
        converted_vacations = convert_vacations(start_time, vacations)

        if @night_mode
          night_offset = work_end_time_minutes.minutes + 1.minute
          start_time -= night_offset
          end_time -= night_offset
          @work_start_time -= night_offset
          @work_end_time -= night_offset
        end

        days_with_work = (start_time.to_date..end_time.to_date).to_a.size

        end_time.to_i - start_time.to_i - off_work_seconds(days_with_work, start_time, end_time, converted_vacations)
      end

      def off_work_seconds(days_with_work, start_time, end_time, converted_vacations)
        result = 0
        days_with_work.times do |day_index|
          if holiday?(start_time + day_index.days, converted_vacations)
            result += reduced_time_by_holiday(start_time, end_time, day_index, days_with_work)
          end

          result += reduce_time_by_off_work_time(day_index, days_with_work) if days_with_work > 1
        end
        result
      end

      def holiday?(current_day, converted_vacations)
        current_day.wday.in?(WEEKEND_DAYS_INDEXES) || current_day.strftime('%Y-%m-%d').in?(converted_vacations)
      end

      def reduced_time_by_holiday(start_time, end_time, day_index, days_with_work)
        return change_date_for_time(work_end_time, start_time).to_i - start_time.to_i if day_index.zero?
        return end_time.to_i - change_date_for_time(work_start_time, end_time).to_i if day_index == days_with_work - 1

        working_seconds
      end

      def reduce_time_by_off_work_time(day_index, days_with_work)
        return (MINUTES_IN_DAY - work_end_time_minutes) * SECONDS_IN_MINUTE if day_index.zero?
        return work_start_time_minutes * SECONDS_IN_MINUTE if day_index == days_with_work - 1

        off_working_seconds
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
          find_average.call(values: value, type: @insightable.configuration.average_type)
        end
      end

      def work_start_time_minutes
        (work_start_time.hour * MINUTES_IN_HOUR) + work_start_time.min
      end

      def work_end_time_minutes
        (work_end_time.hour * MINUTES_IN_HOUR) + work_end_time.min
      end

      # seconds between ending time of previous day and starting time of new day in seconds
      def off_working_seconds
        return work_start_time.to_i - work_end_time.to_i if @night_mode

        work_start_time.to_i - (work_end_time - 1.day).to_i
      end

      def working_seconds
        SECONDS_IN_DAY - off_working_seconds
      end
    end
  end
end
