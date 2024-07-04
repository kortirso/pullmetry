# frozen_string_literal: true

require 'swagger_helper'

# rubocop: disable RSpec/EmptyExampleGroup, RSpec/ScatteredSetup
describe 'api/v1/companies' do
  path '/api/v1/companies' do
    get('List available companies') do
      tags 'Companies'

      description 'List of companies available for user'

      produces 'application/json'
      consumes 'application/json'

      parameter name: :api_access_token, in: :query, type: :string, description: 'API access token', required: true
      parameter name: :include_fields,
                in: :query,
                type: :string,
                description: 'List of attributes should be included in response separated by comma',
                required: false
      parameter name: :exclude_fields,
                in: :query,
                type: :string,
                description: 'List of attributes should be excluded from response separated by comma',
                required: false

      response(200, 'successful') do
        let(:api_access_token) { create(:api_access_token).value }

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
                    uuid: { type: :string },
                    title: { type: :string },
                    repositories_count: { type: :integer, nullable: true },
                    accessable: { type: :boolean }
                  }
                }
              }
            }
          }
        }

        run_test!
      end

      response(401, 'Unauthorized') do
        let(:api_access_token) { 'unexisting' }

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
