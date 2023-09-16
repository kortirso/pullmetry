# frozen_string_literal: true

require 'dry/auto_inject'
require 'dry/container'

module Pullmetry
  class Container
    extend Dry::Container::Mixin

    register('math.find_average') { Math::FindAverage.new }

    # contracts
    register('contracts.companies.create') { Companies::CreateContract.new }
    register('contracts.access_token') { AccessTokenContract.new }
    register('contracts.identity') { IdentityContract.new }
    register('contracts.repository') { RepositoryContract.new }

    # validators
    register('validators.companies.create') { Companies::CreateValidator.new }
    register('validators.access_token') { AccessTokenValidator.new }
    register('validators.identity') { IdentityValidator.new }
    register('validators.repository') { RepositoryValidator.new }
  end
end

Deps = Dry::AutoInject(Pullmetry::Container)
