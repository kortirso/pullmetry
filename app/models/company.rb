# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable

  belongs_to :user
end
