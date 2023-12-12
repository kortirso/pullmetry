# frozen_string_literal: true

# to view cron rules - visit https://crontab.guru

# Synchronize companies
every 1.hour do
  runner 'Import::SyncCompaniesJob.perform_later'
end

# Refresh user achievements
# At minute 15 on every day-of-week from Monday through Friday
every '15 * * * 1-5' do
  runner 'Users::RefreshAchievementsJob.perform_later'
end

# Send insights notifications
every 4.hours do
  runner 'Deliveries::Companies::InsightsReportJob.perform_later'
end

# Send repository insights notifications
every 4.hours do
  runner 'Deliveries::Companies::RepositoryInsightsReportJob.perform_later'
end

# Clear expired users sessions
every 1.day do
  runner 'Users::Sessions::RemoveExpiredJob.perform_later'
end
