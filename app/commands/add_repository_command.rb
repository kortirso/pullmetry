# frozen_string_literal: true

class AddRepositoryCommand < BaseCommand
  HOURS_FOR_OLD_INSIGHTS = 12

  use_contract do
    config.messages.namespace = :repository

    Providers = Dry::Types['strict.string'].enum(Providerable::GITHUB, Providerable::GITLAB)

    params do
      required(:company).filled(type?: Company)
      required(:title).filled(:string)
      required(:link).filled(:string)
      required(:provider).filled(Providers)
      optional(:external_id)
    end

    rule(:provider, :link) do
      unless values[:link].starts_with?(Repository::LINK_FORMAT_BY_PROVIDER[values[:provider]])
        key(:link).failure(:invalid_host)
      end
    end

    rule(:provider, :external_id) do
      if values[:provider] == Providerable::GITLAB && values[:external_id].blank?
        key(:external_id).failure(:empty)
      end
    end

    rule(:link) do
      if values[:link].ends_with?('.git')
        key(:link).failure(:invalid_git)
      end
    end
  end

  private

  def validate_content(input)
    validate_existing_link(input[:company].user, input[:link])
  end

  def do_persist(input)
    repository = Repository.create!(input)

    { result: repository }
  end

  def validate_existing_link(user, link)
    existing_repository = Repository.find_by(link: link)
    return if existing_repository.nil?

    if user.available_repositories.ids.include?(existing_repository.id)
      return 'User has access to repository with the same link'
    end

    return 'Repository with the same link exists' if repository_with_insights_exists?(existing_repository)

    nil if existing_repository.destroy
  end

  def repository_with_insights_exists?(existing_repository)
    ::Insight
      .where(insightable: existing_repository)
      .exists?(['updated_at > ?', HOURS_FOR_OLD_INSIGHTS.hours.ago])
  end
end
