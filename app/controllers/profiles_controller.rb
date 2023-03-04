# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :find_end_time, only: %i[show]
  before_action :find_vacations, only: %i[show]

  def show; end

  def destroy
    current_user.destroy
    session[:pullmetry_token] = nil
    redirect_to root_path, notice: 'Your account is deleted'
  end

  private

  def find_end_time
    @end_time =
      current_user
      .subscriptions
      .where('start_time < :date AND end_time > :date', date: DateTime.now.new_offset(0))
      .maximum(:end_time)
  end

  def find_vacations
    @vacations =
      current_user
      .vacations
      .order(start_time: :desc)
      .load_async
  end
end
