# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Files
        def call(data:)
          data.map do |payload|
            payload = payload.with_indifferent_access
            {
              changed_loc: payload[:changes]
            }
          end
        end
      end
    end
  end
end
