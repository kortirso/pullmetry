# frozen_string_literal: true

module Companies
  class CreateService
    prepend ApplicationService

    def initialize(company_validator: Companies::CreateValidator)
      @company_validator = company_validator
    end

    def call(user:, params:)
      return if validate_with(@company_validator, params) && failure?

      @result = user.companies.new(params)
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
