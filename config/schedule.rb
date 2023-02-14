# frozen_string_literal: true

# Synchronize companies
every 1.hour do
  runner 'Import::SyncCompaniesJob.perform_later'
end

# Send insights notifications
every 4.hours do
  runner 'Export::SendInsightsNotificationJob.perform_later'
end
