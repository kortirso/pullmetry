# frozen_string_literal: true

module Users
  class CreateService
    prepend ApplicationService

    def initialize(user_validator: Users::CreateValidator)
      @user_validator = user_validator
    end

    # rubocop: disable Metrics/CyclomaticComplexity
    def call(params:, with_send_confirmation: true)
      return if validate_with(@user_validator, params) && failure?
      return if validate_user(params) && failure?

      send_email_confirmation if @result.save && with_send_confirmation
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.users.create.email_exists'))
    end
    # rubocop: enable Metrics/CyclomaticComplexity

    private

    def validate_user(params)
      @result = User.new(params)
      return if @result.valid?

      fail!(I18n.t('services.users.create.invalid'))
    end

    def send_email_confirmation
      Users::Auth::SendEmailConfirmationJob.perform_now(id: @result.id)
    end
  end
end
