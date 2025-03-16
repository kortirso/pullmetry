# frozen_string_literal: true

module Admin
  class FeedbacksController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_feedbacks, only: %i[index]

    def index; end

    private

    def find_feedbacks
      @pagy, @feedbacks = pagy(User::Feedback.order(created_at: :desc), limit: PER_PAGE)
    end
  end
end
