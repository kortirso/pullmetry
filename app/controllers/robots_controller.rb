# frozen_string_literal: true

class RobotsController < ApplicationController
  skip_before_action :authenticate

  def index
    render :index, layout: false, formats: :text
  end
end
