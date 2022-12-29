# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable
  include Tokenable

  belongs_to :user

  has_many :repositories, dependent: :destroy
end
