# frozen_string_literal: true

class Identity < ApplicationRecord
  GITHUB = 'github'

  belongs_to :user

  has_many :entities, dependent: :nullify

  enum provider: { GITHUB => 0 }

  def self.find_for_oauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end
end
