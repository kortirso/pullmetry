# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :authenticate

  def index; end

  def privacy; end

  def sources; end
end
