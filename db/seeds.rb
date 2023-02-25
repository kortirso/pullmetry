general_group = Kudos::AchievementGroup.create(name: { en: 'General' })

Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 5,
  rank: 1,
  kudos_achievement_group: general_group,
  title: { en: 'First comment' },
  description: { en: 'Create 1 comment' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 25,
  rank: 2,
  kudos_achievement_group: general_group,
  title: { en: 'Pack of comments' },
  description: { en: 'Create 10 comments' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 50,
  rank: 3,
  kudos_achievement_group: general_group,
  title: { en: 'Comments master' },
  description: { en: 'Create 25 comments' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 100,
  rank: 4,
  kudos_achievement_group: general_group,
  title: { en: 'Comments guru' },
  description: { en: 'Create 50 comments' }
)
Kudos::Achievement.create(
  award_name: 'comment_create',
  points: 250,
  rank: 5,
  kudos_achievement_group: general_group,
  title: { en: 'More comments to the God of comments' },
  description: { en: 'Create 100 comments' }
)
