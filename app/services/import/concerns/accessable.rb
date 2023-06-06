# frozen_string_literal: true

module Import
  module Concerns
    module Accessable
      private

      def mark_repository_as_unaccessable
        Repositories::UpdateService.new
          .call(repository: @repository, params: { accessable: false, synced_at: DateTime.now })
      end
    end
  end
end
