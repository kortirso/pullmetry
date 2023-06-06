# frozen_string_literal: true

return unless Rails.env.production?

# :skippit:
credentials = Rails.application.credentials
Que::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [credentials.dig(:queweb, :user), credentials.dig(:queweb, :password)]
end
# :skippit:
