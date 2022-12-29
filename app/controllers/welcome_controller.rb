# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :check_email_confirmation

  def index; end
end
