# frozen_string_literal: true

module Companies
  class UpdateService
    prepend ApplicationService

    def initialize(company_validator: Companies::UpdateValidator)
      @company_validator = company_validator
    end

    def call(company:, params:, use_work_time:)
      @result = company
      return if validate_with(@company_validator, params) && failure?

      unless use_work_time
        params = params.slice(:title)
        params[:work_start_time] = nil
        params[:work_end_time] = nil
      end
      @result.assign_attributes(params)
      return if validate_work_time && failure?

      @result.save!
    end

    private

    def validate_work_time
      return if @result.work_start_time.nil? || @result.work_end_time.nil?
      return if @result.work_start_time < @result.work_end_time

      fail!('Start time must be before end time')
    end
  end
end
