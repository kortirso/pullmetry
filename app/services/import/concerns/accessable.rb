# frozen_string_literal: true

module Import
  module Concerns
    module Accessable
      private

      def mark_repository_as_unaccessable(repository)
        Pullmetry::Container['services.persisters.repositories.update']
          .call(repository: repository, params: { accessable: false })
      end

      def mark_repository_as_accessable(repository)
        Pullmetry::Container['services.persisters.repositories.update']
          .call(repository: repository, params: { accessable: true })
      end
    end
  end
end
