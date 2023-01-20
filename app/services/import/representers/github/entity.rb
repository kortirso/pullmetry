# frozen_string_literal: true

module Import
  module Representers
    module Github
      class Entity
        def call(data:)
          data = data.with_indifferent_access
          {
            external_id: data[:id].to_s,
            provider: Providerable::GITHUB,
            login: data[:login],
            avatar_url: data[:avatar_url],
            html_url: data[:html_url]
          }
        end
      end
    end
  end
end
