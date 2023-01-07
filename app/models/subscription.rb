# frozen_string_literal: true

class Subscription < ApplicationRecord
  FREE_REPOSITORIES_AMOUNT = 5

  belongs_to :user
end
