# frozen_string_literal: true

class IgnoresController < ApplicationController
  include Deps[create_form: 'forms.ignores.create']

  before_action :find_company, only: %i[new create]
  before_action :find_ignore, only: %i[destroy]

  def new
    @ignore = Ignore.new
  end

  def create
    # commento: ignores.entity_value
    case create_form.call(insightable: @company, params: ignore_params)
    in { errors: errors } then redirect_to new_ignore_path(@company.uuid), alert: errors
    else redirect_to edit_company_configuration_path(@company.uuid)
    end
  end

  def destroy
    authorize! @ignore.insightable, to: :update?
    @ignore.destroy
    redirect_to edit_company_configuration_path(@ignore.insightable.uuid)
  end

  private

  def find_company
    @company = authorized_scope(Company.order(id: :desc)).find_by(uuid: params[:company_id])
    redirect_to companies_path, alert: 'Company is not found' if @company.nil?
  end

  def find_ignore
    @ignore = Ignore.find_by!(uuid: params[:id])
  end

  def ignore_params
    params.require(:ignore).permit(:entity_value)
  end
end
