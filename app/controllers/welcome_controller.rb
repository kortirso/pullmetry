# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :authenticate

  def index; end
end
