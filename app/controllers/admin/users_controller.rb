# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    include Pagy::Backend

    PER_PAGE = 25

    before_action :find_users, only: %i[index]

    def index; end

    private

    def find_users
      @pagy, @users = pagy(User.order(id: :desc), limit: PER_PAGE)
    end
  end
end
