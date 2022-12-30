# frozen_string_literal: true

module Import
  module Representers
    class User
      def call(data:)
        data = data.with_indifferent_access
        {
          external_id: data[:id],
          login: data[:login],
          avatar_url: data[:avatar_url]
        }
      end
    end
  end
end
