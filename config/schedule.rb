# frozen_string_literal: true

# Synchronize companies
every 10.minutes do
  runner 'Import::SyncCompaniesJob.perform_later'
end
