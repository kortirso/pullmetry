# frozen_string_literal: true

module Users
  class Notification < ApplicationRecord
    self.table_name = :users_notifications

    ACCESS_ERROR = 'access_error'

    belongs_to :user, class_name: '::User'

    enum notification_type: {
      ACCESS_ERROR => 0
    }
  end
end
