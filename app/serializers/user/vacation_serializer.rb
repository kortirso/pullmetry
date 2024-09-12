# frozen_string_literal: true

class User
  class VacationSerializer < ApplicationSerializer
    attributes :id, :start_time, :end_time
  end
end
