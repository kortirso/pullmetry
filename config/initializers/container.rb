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

    # lib
    register('math.find_average') { Math::FindAverage.new }
    register('jwt_encoder') { JwtEncoder.new }
    register('dummy') { Dummy.new }
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

    register('services.import.fetchers.github.pull_requests') { Import::Fetchers::Github::PullRequests.new }
    register('services.import.fetchers.github.comments') { Import::Fetchers::Github::Comments.new }
    register('services.import.fetchers.github.reviews') { Import::Fetchers::Github::Reviews.new }
    register('services.import.fetchers.github.files') { Import::Fetchers::Github::Files.new }
    register('services.import.fetchers.gitlab.pull_requests') { Import::Fetchers::Gitlab::PullRequests.new }
    register('services.import.fetchers.gitlab.comments') { Import::Fetchers::Gitlab::Comments.new }
    register('services.import.fetchers.gitlab.reviews') { Import::Fetchers::Gitlab::Reviews.new }

    register('services.import.representers.github.pull_requests') { Import::Representers::Github::PullRequests.new }
    register('services.import.representers.github.comments') { Import::Representers::Github::Comments.new }
    register('services.import.representers.github.reviews') { Import::Representers::Github::Reviews.new }
    register('services.import.representers.github.files') { Import::Representers::Github::Files.new }
    register('services.import.representers.github.entity') { Import::Representers::Github::Entity.new }
    register('services.import.representers.gitlab.pull_requests') { Import::Representers::Gitlab::PullRequests.new }
    register('services.import.representers.gitlab.comments') { Import::Representers::Gitlab::Comments.new }
    register('services.import.representers.gitlab.reviews') { Import::Representers::Gitlab::Reviews.new }
    register('services.import.representers.gitlab.entity') { Import::Representers::Gitlab::Entity.new }

    register('services.import.synchronizers.repositories.github') { Import::Synchronizers::Repositories::Github.new }
    register('services.import.synchronizers.pull_requests.github') { Import::Synchronizers::PullRequests::Github.new }
    register('services.import.synchronizers.comments.github') { Import::Synchronizers::Comments::Github.new }
    register('services.import.synchronizers.reviews.github') { Import::Synchronizers::Reviews::Github.new }
    register('services.import.synchronizers.files.github') { Import::Synchronizers::Files::Github.new }
    register('services.import.synchronizers.repositories.gitlab') { Import::Synchronizers::Repositories::Gitlab.new }
    register('services.import.synchronizers.pull_requests.gitlab') { Import::Synchronizers::PullRequests::Gitlab.new }
    register('services.import.synchronizers.comments.gitlab') { Import::Synchronizers::Comments::Gitlab.new }
    register('services.import.synchronizers.reviews.gitlab') { Import::Synchronizers::Reviews::Gitlab.new }
  end
end

Deps = Dry::AutoInject(Pullmetry::Container)
