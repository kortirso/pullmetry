# frozen_string_literal: true

module Web
  class WelcomeController < ApplicationController
    skip_before_action :authenticate

    before_action :find_active_counters, only: %i[index]

    def index; end

    def privacy; end

    def metrics; end

    def access_tokens; end

    private

    def find_active_counters
      @active_counters =
        Rails.cache.fetch(
          'welcome_index_active_counters_v1',
          expires_in: 24.hours,
          race_condition_ttl: 10.seconds
        ) do
          {
            companies: Company.where.associated(:insights).distinct.count,
            repositories: Repository.where.associated(:insights).distinct.count
          }
        end
    end
  end
end
