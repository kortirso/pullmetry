# frozen_string_literal: true

# Synchronize companies
every 15.minutes do
  runner 'Import::SyncCompaniesJob.perform_later'
end
