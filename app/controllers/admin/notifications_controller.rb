# frozen_string_literal: true

module Admin
  class NotificationsController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_notifications, only: %i[index]

    def index; end

    private

    def find_notifications
      @pagy, @notifications = pagy(Notification.order(id: :desc), items: PER_PAGE)
    end
  end
end
