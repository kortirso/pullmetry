# frozen_string_literal: true

# to view cron rules - visit https://crontab.guru

# At minute 15 on every day-of-week from Monday through Friday
every '15 * * * 1-5' do
  # Refresh user achievements
  runner 'Users::RefreshAchievementsJob.perform_later'
end

every 1.hour do
  # Synchronize companies
  runner 'Import::SyncCompaniesJob.perform_later'
end

every 4.hours do
  # Send insights notifications
  runner 'Deliveries::Companies::InsightsReportJob.perform_later'

  # Send repository insights notifications
  runner 'Deliveries::Companies::RepositoryInsightsReportJob.perform_later'

  # Send long time review notifications
  runner 'Deliveries::Companies::LongTimeReviewReportJob.perform_later'

  # Send long time review notifications
  runner 'Deliveries::Companies::NoNewPullsReportJob.perform_later'
end

# Clear expired users sessions
every 1.day do
  runner 'Users::Sessions::RemoveExpiredJob.perform_later'
end
