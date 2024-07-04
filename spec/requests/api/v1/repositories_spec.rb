# frozen_string_literal: true

require 'swagger_helper'

# rubocop: disable RSpec/EmptyExampleGroup, RSpec/ScatteredSetup
describe 'api/v1/repositories' do
  path '/api/v1/repositories/{id}/insights' do
    get('Insights of developers by repository') do
      tags 'Repositories'

      description 'List of developers insights by repository'

      produces 'application/json'
      consumes 'application/json'

      parameter name: :id, in: :path, type: :string, description: 'Repository UUID', required: true
      parameter name: :api_access_token, in: :query, type: :string, description: 'API access token', required: true

      response(200, 'successful') do
        let(:user) { create :user }
        let(:api_access_token) { create(:api_access_token, user: user).value }
        let(:company) { create :company, user: user }
        let(:repository) { create :repository, company: company }
        let(:id) { repository.uuid }
        let(:insight) { create :insight, insightable: repository }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string },
                attributes: {
                  type: :object,
                  properties: {
                    values: {
                      type: :object
                    },
                    entity: {
                      type: :object,
                      properties: {
                        login: { type: :string },
                        html_url: { type: :string },
                        avatar_url: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          },
          ratio_type: { type: :string, nullable: true }
        }

        run_test!
      end

      response(401, 'Unauthorized') do
        let(:api_access_token) { 'unexisting' }
        let(:id) { 'unexisting' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        schema type: :object, properties: {
          error: {
            type: :array,
            items: { type: :string }
          }
        }

        run_test!
      end
    end
  end
end
# rubocop: enable RSpec/EmptyExampleGroup, RSpec/ScatteredSetup
