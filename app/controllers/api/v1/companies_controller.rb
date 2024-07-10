# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < Api::V1Controller
      SERIALIZER_FIELDS = %w[title repositories_count accessable].freeze

      def index
        render json: Panko::Response.new(
          companies: Panko::ArraySerializer.new(
            companies,
            each_serializer: CompanySerializer,
            **serializer_fields(CompanySerializer, SERIALIZER_FIELDS)
          )
        )
      end

      private

      def companies
        current_user.available_companies.order(id: :desc)
      end
    end
  end
end
