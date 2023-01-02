# frozen_string_literal: true

class Identity < ApplicationRecord
  GITHUB = 'github'

  belongs_to :user

  enum provider: { GITHUB => 0 }

  def self.find_for_oauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end
end
