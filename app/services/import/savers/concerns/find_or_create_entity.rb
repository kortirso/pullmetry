# frozen_string_literal: true

module Import
  module Savers
    module Concerns
      module FindOrCreateEntity
        ENTITY_FIND_ATTRIBUTES = %i[source external_id].freeze

        private

        def find_or_create_entity(payload)
          entity = ::Entity.find_or_initialize_by(payload.slice(*ENTITY_FIND_ATTRIBUTES))
          entity.identity = matched_identity(payload) if entity.new_record?
          entity.update!(payload.except(*ENTITY_FIND_ATTRIBUTES))
          entity.id
        end

        def matched_identity(payload)
          Identity.find_by(provider: payload[:source], login: payload[:login])
        end
      end
    end
  end
end
