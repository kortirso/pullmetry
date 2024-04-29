# frozen_string_literal: true

class SubscribersController < ApplicationController
  include Deps[create_form: 'forms.subscribers.create']

  skip_before_action :authenticate
  before_action :check_recaptcha, only: %i[create]
  before_action :check_double_subscribing, only: %i[create]
  before_action :find_existing_subscriber, only: %i[create]

  def create
    # commento: subscribers.email
    case create_form.call(params: subscriber_params)
    in { errors: errors } then redirect_to root_path, alert: errors
    else
      set_subscriber_in_cookies
      redirect_to root_path, notice: 'You are successfully subscribed for news'
    end
  end

  private

  def check_recaptcha
    redirect_to root_path unless verify_recaptcha
  end

  def check_double_subscribing
    return unless cookies[:pullmetry_subscriber_email]

    redirect_to root_path, alert: 'You can not subscribe for news twice'
  end

  def find_existing_subscriber
    return unless Subscriber.exists?(email: subscriber_params[:email])

    redirect_to root_path, alert: 'This email can not subscribe for news'
  end

  # to avoid subscribing one visitor with many emails
  def set_subscriber_in_cookies
    cookies[:pullmetry_subscriber_email] = {
      value: true,
      expires: 1.month.from_now
    }
  end

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end
