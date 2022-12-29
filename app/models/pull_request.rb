# frozen_string_literal: true

class PullRequest < ApplicationRecord
  include Uuidable

  belongs_to :repository
end
