# frozen_string_literal: true

module RequestMacros
  def sign_in_user
    before do
      @current_user = create :user
      user_session = User::Session.create(user: @current_user)
      cookies[Authkeeper.configuration.access_token_name] =
        Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result]
    end
  end
end
