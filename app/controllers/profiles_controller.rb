# frozen_string_literal: true

class ProfilesController < ApplicationController
  include Deps[
    update_form: 'forms.users.update',
    remove_user: 'commands.remove_user',
    jwt_encoder: 'jwt_encoder',
    to_bool: 'to_bool'
  ]

  before_action :find_api_access_tokens, only: %i[show]
  before_action :find_invites, only: %i[show]
  before_action :find_used_trial_subscription, only: %i[show]
  before_action :find_end_time, only: %i[show]
  before_action :find_vacations, only: %i[show]
  before_action :find_identities, only: %i[show]
  before_action :find_not_attached_identities, only: %i[show]
  before_action :generate_order_ids, only: %i[show]

  def show; end

  def update
    # commento: users.work_start_time, users.work_end_time, users.work_time_zone
    case update_form.call(user: current_user, params: user_params, use_work_time: use_work_time)
    in { errors: errors } then redirect_to profile_path, alert: errors
    else redirect_to profile_path
    end
  end

  def destroy
    remove_user.call(user: current_user)
    cookies.delete(Authkeeper.configuration.access_token_name)
    redirect_to root_path
  end

  private

  def find_api_access_tokens
    @api_access_tokens = current_user.api_access_tokens.hashable_pluck(:uuid, :value)
  end

  def find_invites
    @accepted_invites = current_user.invites.accepted.hashable_pluck(:uuid, :email, :access)
    @invites = current_user.invites.waiting.hashable_pluck(:uuid, :email, :access)
  end

  def find_used_trial_subscription
    @used_trial_subscription = current_user.subscriptions.exists?
  end

  def find_end_time
    @end_time = current_user.subscriptions.active.maximum(:end_time)
  end

  def find_vacations
    @vacations = current_user.vacations.order(start_time: :desc).hashable_pluck(:id, :start_time, :end_time)
  end

  def find_identities
    @identities = current_user.identities.order(provider: :asc).hashable_pluck(:id, :provider, :created_at)
    @must_be_identities = @identities.select do |identity|
      Providerable::MUST_BE_PROVIDERS.include?(identity[:provider])
    end
  end

  def find_not_attached_identities
    @need_identities = Identity.providers.keys - @identities.pluck(:provider)
  end

  # rubocop: disable Metrics/AbcSize
  def generate_order_ids
    @cryptocloud_order_ids =
      Rails.cache.fetch('profile_cryptocloud_order_ids_v1') do
        {
          regular30: jwt_encoder.encode(
            payload: { uuid: current_user.uuid, plan: Subscription::REGULAR, days_period: 30 }
          ),
          regular365: jwt_encoder.encode(
            payload: { uuid: current_user.uuid, plan: Subscription::REGULAR, days_period: 365 }
          ),
          unlimited30: jwt_encoder.encode(
            payload: { uuid: current_user.uuid, plan: Subscription::UNLIMITED, days_period: 30 }
          ),
          unlimited365: jwt_encoder.encode(
            payload: { uuid: current_user.uuid, plan: Subscription::UNLIMITED, days_period: 365 }
          )
        }
      end
  end
  # rubocop: enable Metrics/AbcSize

  def user_params
    params.require(:user).permit(:work_time_zone, :work_start_time, :work_end_time)
  end

  def use_work_time
    to_bool.call(params[:user][:use_work_time])
  end
end
