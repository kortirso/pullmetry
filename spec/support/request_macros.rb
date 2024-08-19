# frozen_string_literal: true

module RequestMacros
  def sign_in_user
    before do
      @current_user = create :user
      users_session = Users::Session.create(user: @current_user)
      cookies[Authkeeper.configuration.access_token_name] =
        Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result]
    end
  end

  def sign_in_admin
    before do
      @current_user = create :user, :admin
      users_session = Users::Session.create(user: @current_user)
      cookies[Authkeeper.configuration.access_token_name] =
        Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result]
    end
  end
end
