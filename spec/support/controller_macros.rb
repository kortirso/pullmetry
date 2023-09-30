# frozen_string_literal: true

module ControllerMacros
  def sign_in_user
    before do
      @current_user = create :user
      @request.session['pullmetry_token'] = Auth::GenerateTokenService.new.call(user: @current_user)[:result]
    end
  end
end
