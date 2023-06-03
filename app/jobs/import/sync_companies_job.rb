# frozen_string_literal: true

module Import
  class SyncCompaniesJob < ApplicationJob
    include Monitoring

    queue_as :default

    def perform
      Company.pluck(:id).each do |id|
        Import::SyncRepositoriesJob.perform_later(id: id)
      end
    end
  end
end
