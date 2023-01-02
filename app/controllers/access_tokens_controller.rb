# frozen_string_literal: true

class AccessTokensController < ApplicationController
  before_action :find_tokenable

  def new
    @access_token = AccessToken.new
  end

  def create
    service_call = AccessTokens::CreateService.call(tokenable: @tokenable, params: access_token_params)
    if service_call.success?
      redirect_to redirect_path, notice: 'Access token is created'
    else
      redirect_to(
        new_access_token_path(tokenable_uuid: @tokenable.uuid, tokenable_type: @tokenable.class.name),
        alert: service_call.errors
      )
    end
  end

  private

  def find_tokenable
    @tokenable =
      case params[:tokenable_type]
      when 'Company' then Current.user.companies.find_by!(uuid: params[:tokenable_uuid])
      when 'Repository' then Current.user.repositories.find_by!(uuid: params[:tokenable_uuid])
      end

    redirect_to companies_path, alert: 'Valid tokenable for access token is not found' unless @tokenable
  end

  def redirect_path
    @tokenable.is_a?(Company) ? companies_path : repositories_path
  end

  def access_token_params
    params.require(:access_token).permit(:value)
  end
end
