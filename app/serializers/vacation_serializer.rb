# frozen_string_literal: true

class VacationSerializer < ApplicationSerializer
  attribute :id, :start_time, :end_time
end
