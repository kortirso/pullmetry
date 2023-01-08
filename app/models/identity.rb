# frozen_string_literal: true

class Identity < ApplicationRecord
  include Providerable

  belongs_to :user

  has_many :entities, dependent: :nullify
end
