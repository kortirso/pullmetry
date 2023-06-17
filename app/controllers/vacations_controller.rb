# frozen_string_literal: true

class VacationsController < ApplicationController
  before_action :find_vacation, only: %i[destroy]

  def new
    @vacation = Vacation.new
  end

  def create
    service_call = Vacations::CreateService.call(user: current_user, params: vacation_params)
    if service_call.success?
      redirect_to profile_path, notice: 'Vacation is added'
    else
      redirect_to new_vacation_path, alert: service_call.errors
    end
  end

  def destroy
    @vacation.destroy
    redirect_to profile_path, notice: 'Vacation is deleted'
  end

  private

  def find_vacation
    @vacation = current_user.vacations.find_by(id: params[:id])
    redirect_to profile_path, alert: 'Vacation is not found' if @vacation.nil?
  end

  def vacation_params
    params.require(:vacation).permit(:start_time, :end_time)
  end
end
