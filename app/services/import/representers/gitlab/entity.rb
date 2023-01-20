# frozen_string_literal: true

module Import
  module Representers
    module Gitlab
      class Entity
        def call(data:)
          data = data.with_indifferent_access
          {
            external_id: data[:id].to_s,
            provider: Providerable::GITLAB,
            login: data[:username],
            avatar_url: data[:avatar_url],
            html_url: data[:web_url]
          }
        end
      end
    end
  end
end
