# frozen_string_literal: true

module Web
  class ProfilesController < ApplicationController
    include Deps[
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

    def destroy
      remove_user.call(user: current_user)
      cookies.delete(Authkeeper.configuration.access_token_name)
      redirect_to root_path
    end

    private

    def find_api_access_tokens
      @api_access_tokens = current_user.api_access_tokens.hashable_pluck(:id, :value)
    end

    def find_invites
      @accepted_invites = current_user.invites.accepted.hashable_pluck(:id, :email, :access)
      @invites = current_user.invites.waiting.hashable_pluck(:id, :email, :access)
    end

    def find_used_trial_subscription
      @trial_subscription_is_used = current_user.subscriptions.exists?
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

    def generate_order_ids
      @cryptocloud_order_ids =
        Rails.cache.fetch('profile_cryptocloud_order_ids_v2') do
          {
            regular30: jwt_encoder.encode(
              payload: { uuid: current_user.id, days_period: 30 }
            ),
            regular365: jwt_encoder.encode(
              payload: { uuid: current_user.id, days_period: 365 }
            )
          }
        end
    end
  end
end
