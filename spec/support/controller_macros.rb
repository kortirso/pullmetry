# frozen_string_literal: true

module ControllerMacros
  def sign_in_user
    before do
      @current_user = create :user
      user_session = User::Session.create(user: @current_user)
      @request.cookies[Authkeeper.configuration.access_token_name] =
        Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result]
    end
  end

  def sign_in_admin
    before do
      @current_user = create :user, :admin
      user_session = User::Session.create(user: @current_user)
      @request.cookies[Authkeeper.configuration.access_token_name] =
        Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result]
    end
  end
end
