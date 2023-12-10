# frozen_string_literal: true

class NotificationValidator < ApplicationValidator
  include Deps[contract: 'contracts.notification']
end
