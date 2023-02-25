general_group = Kudos::AchievementGroup.create(name: { en: 'General' })

Kudos::Achievement.create(award_name: 'comment_create', points: 5, rank: 1, kudos_achievement_group: general_group)
Kudos::Achievement.create(award_name: 'comment_create', points: 25, rank: 2, kudos_achievement_group: general_group)
Kudos::Achievement.create(award_name: 'comment_create', points: 50, rank: 3, kudos_achievement_group: general_group)
Kudos::Achievement.create(award_name: 'comment_create', points: 100, rank: 4, kudos_achievement_group: general_group)
Kudos::Achievement.create(award_name: 'comment_create', points: 250, rank: 5, kudos_achievement_group: general_group)
