# frozen_string_literal: true

module Persisters
  module Repositories
    class UpdateService
      def call(repository:, params:)
        repository.update!(params)
      end
    end
  end
end
