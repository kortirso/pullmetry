# frozen_string_literal: true

module Admin
  class SubscribersController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_subscribers, only: %i[index]

    def index; end

    private

    def find_subscribers
      @pagy, @subscribers = pagy(Subscriber.order(id: :desc), limit: PER_PAGE)
    end
  end
end
