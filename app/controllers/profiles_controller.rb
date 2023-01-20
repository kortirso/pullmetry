# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show; end

  def destroy
    Current.user.destroy
    session[:pullmetry_token] = nil
    redirect_to root_path, notice: 'Your account is deleted'
  end
end
