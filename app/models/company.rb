# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable

  belongs_to :user

  has_many :repositories, dependent: :destroy
end
