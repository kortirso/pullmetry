# frozen_string_literal: true

module Admin
  class FeedbacksController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_feedbacks, only: %i[index]

    def index; end

    private

    def find_feedbacks
      @pagy, @feedbacks = pagy(Feedback.includes(:user).order(id: :desc), items: PER_PAGE)
    end
  end
end
