# frozen_string_literal: true

module Import
  module Concerns
    module Serviceable
      private

      def fetch_service
        "Import::Fetchers::#{@provider}::#{@service_name}".constantize
      end

      def represent_service
        "Import::Representers::#{@provider}::#{@service_name}".constantize
      end

      def save_service
        "Import::Savers::#{@service_name}".constantize
      end
    end
  end
end
