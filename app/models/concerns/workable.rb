# frozen_string_literal: true

module Workable
  extend ActiveSupport::Concern

  included do
    has_one :work_time, as: :worktimeable, dependent: :destroy
  end

  def with_work_time?
    work_time.present?
  end
end
