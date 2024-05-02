# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < Api::V1Controller
      SERIALIZER_FIELDS = %w[title repositories_count accessable].freeze

      def index
        render json: { companies: companies }, status: :ok
      end

      private

      def companies
        CompanySerializer.new(
          current_user.available_companies.order(id: :desc),
          params: serializer_fields(CompanySerializer, SERIALIZER_FIELDS)
        ).serializable_hash
      end
    end
  end
end
