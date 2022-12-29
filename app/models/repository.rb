# frozen_string_literal: true

class Repository < ApplicationRecord
  include Uuidable

  belongs_to :company
end
