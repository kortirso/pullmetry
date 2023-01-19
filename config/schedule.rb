# frozen_string_literal: true

# Synchronize companies
every 1.hour do
  runner 'Import::SyncCompaniesJob.perform_later'
end
