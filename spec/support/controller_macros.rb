# frozen_string_literal: true

module ControllerMacros
  def sign_in_user
    before do
      @current_user = create :user
      @request.cookies['pullmetry_token'] = Auth::GenerateTokenService.new.call(user: @current_user)[:result]
    end
  end

  def sign_in_admin
    before do
      @current_user = create :user, :admin
      @request.cookies['pullmetry_token'] = Auth::GenerateTokenService.new.call(user: @current_user)[:result]
    end
  end
end
