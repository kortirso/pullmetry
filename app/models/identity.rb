# frozen_string_literal: true

class Identity < ApplicationRecord
  include Providerable

  belongs_to :user

  has_many :entities, dependent: :nullify

  def self.find_for_oauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end
end
