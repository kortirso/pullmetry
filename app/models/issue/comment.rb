# frozen_string_literal: true

class Issue
  class Comment < ApplicationRecord
    include Uuidable

    belongs_to :issue
  end
end
