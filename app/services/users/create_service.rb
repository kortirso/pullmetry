# frozen_string_literal: true

module Users
  class CreateService
    prepend ApplicationService
    include Validateable

    def initialize(user_validator: UserValidator)
      @user_validator = user_validator
    end

    def call(params:)
      return if validate_with(@user_validator, params) && failure?

      @result = User.create!(params)
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.users.create.email_exists'))
    end
  end
end
