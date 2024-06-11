# frozen_string_literal: true

class Feedback < ApplicationRecord
  encrypts :email

  belongs_to :user
end
