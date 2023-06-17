# frozen_string_literal: true

# Synchronize companies
every 1.hour do
  runner 'Import::SyncCompaniesJob.perform_later'
end

# Refresh user achievements
every '15 * * * 1-5' do
  runner 'Users::RefreshAchievementsJob.perform_later'
end

# Send insights notifications
every 4.hours do
  runner 'Export::SendInsightsNotificationJob.perform_later'
end

# Clear expired users sessions
every 1.day do
  runner 'Users::Sessions::RemoveExpiredJob.perform_later'
end
