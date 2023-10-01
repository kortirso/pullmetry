# frozen_string_literal: true

module Import
  module Concerns
    module Accessable
      private

      def mark_repository_as_unaccessable(repository)
        Repositories::UpdateService.new
          .call(repository: repository, params: { accessable: false })
      end

      def mark_repository_as_accessable(repository)
        Repositories::UpdateService.new
          .call(repository: repository, params: { accessable: true })
      end
    end
  end
end
