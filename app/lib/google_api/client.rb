# frozen_string_literal: true

module GoogleApi
  class Client < HttpService::Client
    include Requests::User

    BASE_URL = 'https://www.googleapis.com'

    option :url, default: proc { BASE_URL }
  end
end
