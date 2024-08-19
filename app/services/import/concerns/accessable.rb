# frozen_string_literal: true

module Import
  module Concerns
    module Accessable
      private

      def mark_repository_as_unaccessable(repository)
        Pullmetry::Container['commands.change_repository']
          .call(repository: repository, accessable: false)
      end

      def mark_repository_as_accessable(repository)
        Pullmetry::Container['commands.change_repository']
          .call(repository: repository, accessable: true)
      end
    end
  end
end
