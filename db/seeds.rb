general_group = Kudos::AchievementGroup.create(name: { en: 'General' })
comments_group = Kudos::AchievementGroup.create(name: { en: 'Comments' }, parent: general_group)
reviews_group = Kudos::AchievementGroup.create(name: { en: 'Reviews' }, parent: general_group)
prs_group = Kudos::AchievementGroup.create(name: { en: 'Pull requests' }, parent: general_group)

Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 5,
  rank: 1,
  kudos_achievement_group: comments_group,
  title: { en: 'First comment' },
  description: { en: 'Create 1 comment' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 10,
  rank: 2,
  kudos_achievement_group: comments_group,
  title: { en: 'Pack of comments' },
  description: { en: 'Create 10 comments' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 25,
  rank: 3,
  kudos_achievement_group: comments_group,
  title: { en: 'Comments master' },
  description: { en: 'Create 25 comments' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 50,
  rank: 4,
  kudos_achievement_group: comments_group,
  title: { en: 'Comments guru' },
  description: { en: 'Create 50 comments' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 100,
  rank: 5,
  kudos_achievement_group: comments_group,
  title: { en: 'More comments to the God of comments' },
  description: { en: 'Create 100 comments' }
)

Kudos::Achievement.create(
  award_name: 'review_create',
  points: 5,
  rank: 1,
  kudos_achievement_group: reviews_group,
  title: { en: 'First approve' },
  description: { en: 'Approve 1 pull request' }
)
Kudos::Achievement.create(
  award_name: 'review_create',
  points: 10,
  rank: 2,
  kudos_achievement_group: reviews_group,
  title: { en: 'Good progress' },
  description: { en: 'Approve 10 pull requests' }
)
Kudos::Achievement.create(
  award_name: 'review_create',
  points: 25,
  rank: 3,
  kudos_achievement_group: reviews_group,
  title: { en: "Merges don't wait" },
  description: { en: 'Approve 25 pull requests' }
)
Kudos::Achievement.create(
  award_name: 'review_create',
  points: 50,
  rank: 4,
  kudos_achievement_group: reviews_group,
  title: { en: 'Did you really check them?' },
  description: { en: 'Approve 50 pull requests' }
)
Kudos::Achievement.create(
  award_name: 'review_create',
  points: 100,
  rank: 5,
  kudos_achievement_group: reviews_group,
  title: { en: 'Approvinator' },
  description: { en: 'Approve 100 pull requests' }
)

Kudos::Achievement.create(
  award_name: 'pull_request_create',
  points: 5,
  rank: 1,
  kudos_achievement_group: prs_group,
  title: { en: 'First open pull request' },
  description: { en: 'Open 1 pull request' }
)
Kudos::Achievement.create(
  award_name: 'pull_request_create',
  points: 10,
  rank: 2,
  kudos_achievement_group: prs_group,
  title: { en: 'Good push' },
  description: { en: 'Open 10 pull requests' }
)
Kudos::Achievement.create(
  award_name: 'pull_request_create',
  points: 25,
  rank: 3,
  kudos_achievement_group: prs_group,
  title: { en: 'Real developer' },
  description: { en: 'Open 25 pull requests' }
)
Kudos::Achievement.create(
  award_name: 'pull_request_create',
  points: 50,
  rank: 4,
  kudos_achievement_group: prs_group,
  title: { en: 'Awesome 50' },
  description: { en: 'Open 50 pull requests' }
)
Kudos::Achievement.create(
  award_name: 'pull_request_create',
  points: 100,
  rank: 5,
  kudos_achievement_group: prs_group,
  title: { en: "It's not real" },
  description: { en: 'Open 100 pull requests' }
)

10.times do |index|
  user = User.create!(email: "user#{index}@gmail.com")

  Entity.create!(
    provider: 'github',
    login: "octocat_#{index}",
    external_id: index,
    avatar_url: 'https://avatars.githubusercontent.com/u/583231?v=4',
    html_url: "https://github.com/octocat_#{index}"
  )

  Identities::CreateForm.call(
    user: user,
    params: { uid: index.to_s, provider: 'github', email: "user#{index}@gmail.com", login: "octocat_#{index}" }
  )
end
user = User.first
user.update(role: User::ADMIN)
Subscription.create(user: user, start_time: 1.day.ago, end_time: 1.year.after)
7.times do |company_index|
  company = Company.create(title: "Test company #{company_index + 1}", user: User.all.sample)
  3.times do |repository_index|
    repository = Repositories::CreateService.call(
      company: company,
      params: {
        title: "Test #{company_index + 1} #{repository_index + 1}",
        link: "https://github.com/octocat_#{company_index + 1}_#{repository_index + 1}/first",
        provider: 'github'
      }
    ).result

    Entity.all.each_with_index do |entity, entity_index|
      # old pull requests
      rand(6).times do |index|
        pull_request = PullRequest.create!(
          repository: repository,
          entity: entity,
          pull_number: entity_index * 100 + index,
          pull_created_at: (index - 40).days.ago
        )
        # approves
        if [true, false].sample
          approve_entity = Entity.where.not(id: entity.id).sample
          pre = PullRequests::Entity.find_or_create_by(pull_request: pull_request, entity: approve_entity)
          PullRequests::Review.create!(
            pull_requests_entity: pre,
            external_id: SecureRandom.uuid,
            review_created_at: (index - 40).days.ago + rand(120).minutes
          )
        end
        # comments
        rand(5).times do
          comment_entity = Entity.where.not(id: entity.id).sample
          pre = PullRequests::Entity.find_or_create_by(pull_request: pull_request, entity: comment_entity)
          PullRequests::Comment.create!(
            pull_requests_entity: pre,
            external_id: SecureRandom.uuid,
            comment_created_at: (index - 40).days.ago + rand(60).minutes
          )
        end
      end
      # open pull requests
      rand(6).times do |index|
        pull_request = PullRequest.create!(
          repository: repository,
          entity: entity,
          pull_number: entity_index * 100 + index,
          pull_created_at: (index + 1).days.ago
        )
        # approves
        if [true, false].sample
          approve_entity = Entity.where.not(id: entity.id).sample
          pre = PullRequests::Entity.find_or_create_by(pull_request: pull_request, entity: approve_entity)
          PullRequests::Review.create!(
            pull_requests_entity: pre,
            external_id: SecureRandom.uuid,
            review_created_at: (index + 1).days.ago + rand(120).minutes
          )
        end
        # comments
        rand(5).times do
          comment_entity = Entity.where.not(id: entity.id).sample
          pre = PullRequests::Entity.find_or_create_by(pull_request: pull_request, entity: comment_entity)
          PullRequests::Comment.create!(
            pull_requests_entity: pre,
            external_id: SecureRandom.uuid,
            comment_created_at: (index + 1).days.ago + rand(60).minutes
          )
        end
      end
    end
    Insights::GenerateService.call(insightable: repository)
  end
  Insights::GenerateService.call(insightable: company)
end
Users::RefreshAchievementsService.call
