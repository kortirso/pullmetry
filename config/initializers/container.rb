# frozen_string_literal: true

require 'dry/auto_inject'
require 'dry/container'

module Pullmetry
  class Container
    extend Dry::Container::Mixin

    DEFAULT_OPTIONS = { memoize: true }.freeze

    class << self
      def register(key)
        super(key, DEFAULT_OPTIONS)
      end
    end

    register('math.find_average') { Math::FindAverage.new }
    register('jwt_encoder') { JwtEncoder.new }
    register('api.github.auth_client') { GithubAuthApi::Client.new }
    register('api.github.client') { GithubApi::Client.new }
    register('api.gitlab.auth_client') { GitlabAuthApi::Client.new }
    register('api.gitlab.client') { GitlabApi::Client.new }

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

    # forms
    register('forms.companies.create') { Companies::CreateForm.new }
    register('forms.access_tokens.create') { AccessTokens::CreateForm.new }
    register('forms.identities.create') { Identities::CreateForm.new }
    register('forms.repositories.create') { Repositories::CreateForm.new }
    register('forms.vacations.create') { Vacations::CreateForm.new }

    # services
    register('services.auth.attach_identity') { Auth::AttachIdentityService.new }
    register('services.auth.fetch_session') { Auth::FetchSessionService.new }
    register('services.auth.generate_token') { Auth::GenerateTokenService.new }
    register('services.auth.login_user') { Auth::LoginUserService.new }
    register('services.auth.providers.github') { Auth::Providers::Github.new }
    register('services.auth.providers.gitlab') { Auth::Providers::Gitlab.new }

    register('services.persisters.companies.update') { Persisters::Companies::UpdateService.new }
    register('services.persisters.repositories.update') { Persisters::Repositories::UpdateService.new }
    register('services.persisters.subscriptions.add') { Persisters::Subscriptions::AddService.new }
    register('services.persisters.users.destroy') { Persisters::Users::DestroyService.new }
    register('services.persisters.users.refresh_achievements') { Persisters::Users::RefreshAchievementsService.new }

    register('services.converters.seconds_to_text') { Converters::SecondsToTextService.new }
  end
end

Deps = Dry::AutoInject(Pullmetry::Container)
