# frozen_string_literal: true

module Web
  class IdentitiesController < ApplicationController
    before_action :find_identity, only: %i[destroy]
    before_action :check_identity_count, only: %i[destroy]

    def destroy
      @identity.destroy
      redirect_to profile_path
    end

    private

    def find_identity
      @identity = current_user.identities.find_by(id: params[:id])
      redirect_to profile_path, alert: 'Identity is not found' if @identity.nil?
    end

    def check_identity_count
      return if current_user.identities.count > 1

      redirect_to profile_path, alert: 'At least 1 identity must exist'
    end
  end
end
