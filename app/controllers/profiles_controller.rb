# frozen_string_literal: true

class ProfilesController < ApplicationController
  include Deps[destroy_service: 'services.persisters.users.destroy']
  include Boolable

  before_action :find_used_trial_subscription, only: %i[show]
  before_action :find_end_time, only: %i[show]
  before_action :find_vacations, only: %i[show]
  before_action :find_identities, only: %i[show]
  before_action :find_not_attached_identities, only: %i[show]

  def show; end

  def update
    service_call = Users::UpdateForm.call(
      user: current_user,
      params: user_params,
      use_work_time: to_bool(params[:user][:use_work_time]),
      notification_params: notification_params.transform_values { |value| to_bool(value) }
    )
    if service_call.success?
      redirect_to profile_path
    else
      redirect_to profile_path, alert: service_call.errors
    end
  end

  def destroy
    destroy_service.call(user: current_user)
    session[:pullmetry_token] = nil
    redirect_to root_path
  end

  private

  def find_used_trial_subscription
    @used_trial_subscription = current_user.subscriptions.exists?
  end

  def find_end_time
    @end_time = current_user.subscriptions.active.maximum(:end_time)
  end

  def find_vacations
    @vacations = current_user.vacations.order(start_time: :desc).load_async
  end

  def find_identities
    @identities = current_user.identities.order(provider: :asc).hashable_pluck(:provider, :created_at)
  end

  def find_not_attached_identities
    @need_identities = Identity.providers.keys - @identities.pluck(:provider)
  end

  def user_params
    params.require(:user).permit(:work_time_zone, :work_start_time, :work_end_time)
  end

  def notification_params
    params.require(:user).permit(:access_error)
  end
end
