# frozen_string_literal: true

class SitemapsController < ApplicationController
  skip_before_action :authenticate

  def index
    render file: Rails.public_path.join('sitemap.xml'), layout: false, formats: :xml
  end
end
