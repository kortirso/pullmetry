# frozen_string_literal: true

class AccessTokensController < ApplicationController
  include Deps[add_access_token: 'commands.add_access_token']

  before_action :find_company
  before_action :find_repository

  def new
    authorize! @tokenable, to: :update?
    @access_token = AccessToken.new
  end

  def create
    authorize! @tokenable, to: :update?
    # commento: access_tokens.value, access_tokens.expired_at
    case add_access_token.call(access_token_params.merge(tokenable: @tokenable))
    in { errors: errors } then redirect_to fail_redirect_path, alert: errors
    else redirect_to success_redirect_path
    end
  end

  private

  def find_company
    return unless params[:company_id]

    @tokenable = Company.find_by!(uuid: params[:company_id])
    redirect_to companies_path, alert: 'Valid company for access token is not found' unless @tokenable
  end

  def find_repository
    return if @tokenable
    return unless params[:repository_id]

    @tokenable = current_user.repositories.find_by!(uuid: params[:repository_id])
    redirect_to companies_path, alert: 'Valid repository for access token is not found' unless @tokenable
  end

  def success_redirect_path
    return companies_path if @tokenable.is_a?(Company)

    repositories_path
  end

  def fail_redirect_path
    return new_company_access_token_path(@tokenable.uuid) if @tokenable.is_a?(Company)

    new_repository_access_token_path(@tokenable.uuid)
  end

  def access_token_params
    params.require(:access_token).permit(:value, :expired_at).to_h
  end
end
