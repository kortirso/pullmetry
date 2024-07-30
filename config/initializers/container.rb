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
    register('to_bool') { ToBool.new }
    register('api.github.auth_client') { GithubAuthApi::Client.new }
    register('api.github.client') { GithubApi::Client.new }
    register('api.gitlab.auth_client') { GitlabAuthApi::Client.new }
    register('api.gitlab.client') { GitlabApi::Client.new }
    register('api.slack.client') { SlackHooksApi::Client.new }
    register('api.discord.client') { DiscordApi::Client.new }
    register('api.telegram.client') { TelegramApi::Client.new }
    register('bot.telegram.client') { TelegramBot::Client.new }
    register('api.google.auth_client') { GoogleAuthApi::Client.new }
    register('api.google.client') { GoogleApi::Client.new }
    register('monitoring.providers.bugsnag') { Monitoring::Providers::Bugsnag.new }
    register('monitoring.client') { Monitoring::Client.new }

    # commands
    register('commands.add_access_token') { AddAccessTokenCommand.new }
    register('commands.remove_access_token') { RemoveAccessTokenCommand.new }
    register('commands.add_api_access_token') { AddApiAccessTokenCommand.new }
    register('commands.add_company') { AddCompanyCommand.new }
    register('commands.attach_user_to_company') { AttachUserToCompanyCommand.new }
    register('commands.add_identity') { AddIdentityCommand.new }
    register('commands.associate_entities_with_identity') { AssociateEntitiesWithIdentityCommand.new }
    register('commands.add_repository') { AddRepositoryCommand.new }
    register('commands.add_webhook') { AddWebhookCommand.new }
    register('commands.add_feedback') { AddFeedbackCommand.new }
    register('commands.add_notification') { AddNotificationCommand.new }
    register('commands.add_invite') { AddInviteCommand.new }
    register('commands.add_subscriber') { AddSubscriberCommand.new }
    register('commands.add_ignore') { AddIgnoreCommand.new }

    # contracts
    register('contracts.excludes.rule') { Excludes::RuleContract.new }

    # validators
    register('validators.excludes.rules.create') { Excludes::Rules::CreateValidator.new }

    # forms
    register('forms.vacations.create') { Vacations::CreateForm.new }
    register('forms.excludes.groups.create') { Excludes::Groups::CreateForm.new }
    register('forms.users.update') { Users::UpdateForm.new }
    register('forms.companies.configurations.update') { Companies::Configurations::UpdateForm.new }

    # notifiers reports
    register('notifiers.payloads.company') { Payloads::Company.new }
    register('reports.company.custom.insights') { Reports::Company::Custom::Insights.new }
    register('reports.company.custom.long_time_review') { Reports::Company::Custom::LongTimeReview.new }
    register('reports.company.custom.repository_insights') { Reports::Company::Custom::RepositoryInsights.new }
    register('reports.company.custom.no_new_pulls') { Reports::Company::Custom::NoNewPulls.new }
    register('reports.company.telegram.insights') { Reports::Company::Telegram::Insights.new }
    register('reports.company.telegram.long_time_review') { Reports::Company::Telegram::LongTimeReview.new }
    register('reports.company.telegram.repository_insights') { Reports::Company::Telegram::RepositoryInsights.new }
    register('reports.company.telegram.no_new_pulls') { Reports::Company::Telegram::NoNewPulls.new }
    register('reports.company.discord.insights') { Reports::Company::Discord::Insights.new }
    register('reports.company.discord.long_time_review') { Reports::Company::Discord::LongTimeReview.new }
    register('reports.company.discord.repository_insights') { Reports::Company::Discord::RepositoryInsights.new }
    register('reports.company.discord.no_new_pulls') { Reports::Company::Discord::NoNewPulls.new }
    register('reports.company.slack.insights') { Reports::Company::Slack::Insights.new }
    register('reports.company.slack.long_time_review') { Reports::Company::Slack::LongTimeReview.new }
    register('reports.company.slack.repository_insights') { Reports::Company::Slack::RepositoryInsights.new }
    register('reports.company.slack.no_new_pulls') { Reports::Company::Slack::NoNewPulls.new }

    # services
    register('services.auth.attach_identity') { Auth::AttachIdentityService.new }
    register('services.auth.fetch_session') { Auth::FetchSessionService.new }
    register('services.auth.generate_token') { Auth::GenerateTokenService.new }
    register('services.auth.login_user') { Auth::LoginUserService.new }
    register('services.auth.providers.github') { Auth::Providers::Github.new }
    register('services.auth.providers.gitlab') { Auth::Providers::Gitlab.new }
    register('services.auth.providers.telegram') { Auth::Providers::Telegram.new }
    register('services.auth.providers.google') { Auth::Providers::Google.new }

    register('services.persisters.companies.update') { Persisters::Companies::UpdateService.new }
    register('services.persisters.repositories.update') { Persisters::Repositories::UpdateService.new }
    register('services.persisters.subscriptions.add') { Persisters::Subscriptions::AddService.new }
    register('services.persisters.users.destroy') { Persisters::Users::DestroyService.new }
    register('services.persisters.invites.accept') { Persisters::Invites::AcceptService.new }

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
    register('services.import.ignore') { Import::IgnoreService.new }
  end
end

Deps = Dry::AutoInject(Pullmetry::Container)
