# frozen_string_literal: true

module Import
  module Savers
    module Concerns
      module FindOrCreateEntity
        ENTITY_FIND_ATTRIBUTES = %i[provider external_id].freeze
        IDENTITY_FIND_ATTRIBUTES = %i[provider login].freeze

        private

        def author_entity
          @author_entity ||=
            ::PullRequests::Entity.find_by(
              pull_request: @pull_request,
              origin: ::PullRequests::Entity::AUTHOR
            ).entity_id
        end

        def find_or_create_entity(payload)
          entity = ::Entity.find_or_initialize_by(payload.slice(*ENTITY_FIND_ATTRIBUTES))
          entity.identity = matched_identity(payload) if entity.new_record?
          entity.update!(payload.except(*ENTITY_FIND_ATTRIBUTES))
          entity.id
        end

        def matched_identity(payload)
          Identity.find_by(payload.slice(*IDENTITY_FIND_ATTRIBUTES))
        end
      end
    end
  end
end
