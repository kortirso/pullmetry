# frozen_string_literal: true

class Issue
  class Comment < ApplicationRecord
    belongs_to :issue
  end
end
