# frozen_string_literal: true

module Views
  module Shared
    class CheckBoxComponent < ApplicationViewComponent
      def initialize(form:, label:, field:, checked:, position: :left)
        @form = form
        @label = label
        @field = field
        @checked = checked
        @position = position

        super()
      end
    end
  end
end
