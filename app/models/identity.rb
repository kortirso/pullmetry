# frozen_string_literal: true

class Identity < ApplicationRecord
  include Providerable

  encrypts :email, deterministic: true

  belongs_to :user

  has_many :entities, dependent: :nullify
end
