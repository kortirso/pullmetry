# frozen_string_literal: true

module Excludes
  module Groups
    class CreateForm
      def call(company:)
        { result: company.excludes_groups.create! }
      end
    end
  end
end
