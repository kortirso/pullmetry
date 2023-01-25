# frozen_string_literal: true

module GithubGraphqlApi
  class Client < HttpService::Client
    BASE_URL = 'https://api.github.com'

    option :url, default: proc { BASE_URL }
    option :access_token

    # example of graphql request
    # access token should be classic with Full control of private repositories == unsecure
    # query = <<~EOS
    #   query($owner: String!, $name: String!) {
    #     repository(owner: $owner, name: $name) {
    #       pullRequests(last: 100) {
    #         nodes {
    #           author {
    #             login
    #           }
    #           comments(last: 100) {
    #             nodes {
    #               databaseId
    #               createdAt
    #             }
    #           }
    #           reviews(last: 100) {
    #             nodes {
    #               databaseId
    #               submittedAt
    #             }
    #           }
    #           databaseId
    #           createdAt
    #         }
    #       }
    #     }
    #   }
    # EOS
    # client = GithubGraphqlApi::Client.new(access_token: access_token)
    # response = client.request(query: query, variables: { owner: owner, name: name })

    def request(query:, variables:)
      post(
        path: 'graphql',
        body: { query: query, variables: variables },
        headers: headers
      )
    end

    private

    def headers
      {
        'Accept' => 'application/vnd.github+json',
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@access_token}"
      }
    end
  end
end
