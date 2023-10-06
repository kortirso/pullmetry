# frozen_string_literal: true

module Import
  class SyncRepositoriesJob < ApplicationJob
    include Worktimeable

    queue_as :default

    def perform(id:)
      company = Company.find_by(id: id)
      return unless company
      return unless working_time?(company)

      Import::CompanyService.new.call(company: company)
    end
  end
end
