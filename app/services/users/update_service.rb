# frozen_string_literal: true

module Users
  class UpdateService
    prepend ApplicationService

    def call(user:, params:, use_work_time:, notification_params:)
      @params = params

      convert_working_time(use_work_time)
      return if use_work_time && validate_work_time && failure?

      ActiveRecord::Base.transaction do
        refresh_notifications(user, notification_params)
        user.update!(@params)
      end
    end

    private

    def convert_working_time(use_work_time)
      @params[:work_start_time] = use_work_time ? DateTime.new(2023, 1, 1, time(:start, 4), time(:start, 5)) : nil
      @params[:work_end_time] = use_work_time ? DateTime.new(2023, 1, 1, time(:end, 4), time(:end, 5)) : nil

      @params = @params.delete_if { |k, _v| k.include?('_time(') }
    end

    def time(name, index)
      @params["work_#{name}_time(#{index}i)"].to_i
    end

    def validate_work_time
      return if @params[:work_start_time] != @params[:work_end_time]

      fail!('Start and end time must be different')
    end

    def refresh_notifications(user, notification_params)
      existing_notifications = user.notifications.load

      notification_params.each do |key, value|
        notification = existing_notifications.find { |element| element.notification_type == key }
        next user.notifications.create!(value: value, notification_type: key) if notification.nil?

        if notification.value != value
          notification.update!(value: value)
        end
      end
    end
  end
end
