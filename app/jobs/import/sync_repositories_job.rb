# frozen_string_literal: true

module Import
  class SyncRepositoriesJob < ApplicationJob
    queue_as :default

    def perform(id:)
      company = Company.find_by(id: id)
      return unless company

      Import::SyncRepositoriesService.call(company: company)
    end
  end
end
