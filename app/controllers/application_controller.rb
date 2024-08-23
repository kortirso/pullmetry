# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  append_view_path Rails.root.join('app/views/controllers')

  include Authkeeper::Controllers::Authentication
  include Invitationable

  authorize :user, through: :current_user

  # TODO: remember to skip redundant before actions in Api::V1Controller, Api::FrontendController, Admin::BaseController
  before_action :authenticate, except: %i[not_found]
  before_action :find_invite, except: %i[not_found]

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found
  rescue_from ActionPolicy::Unauthorized, with: :access_denied

  # rubocop: disable Lint/UselessMethodDefinition
  # https://github.com/dry-rb/dry-auto_inject/issues/91
  def initialize = super
  # rubocop: enable Lint/UselessMethodDefinition

  def not_found = page_not_found

  private

  def page_not_found
    render template: 'shared/404', status: :not_found, formats: [:html]
  end

  def access_denied
    render template: 'shared/access', status: :unauthorized, formats: [:html]
  end
end
