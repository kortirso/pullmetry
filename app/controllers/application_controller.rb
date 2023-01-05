# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  append_view_path Rails.root.join('app/views/controllers')

  include Authentication

  authorize :user, through: :current_user

  before_action :authenticate, except: %i[page_not_found]

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  def page_not_found
    render template: 'shared/404', status: :not_found, formats: [:html]
  end
end
