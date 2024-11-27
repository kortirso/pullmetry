# frozen_string_literal: true

module PageWrappers
  class UserComponent < ApplicationViewComponent
    attr_reader :current_user

    def initialize(current_user: nil, meta_title: nil, meta_description: nil)
      @current_user = current_user
      @meta_title = meta_title || default_meta_title
      @meta_description = meta_description || default_meta_description

      super()
    end

    private

    def default_meta_title
      'PullKeeper | Open source pull requests analysis & insights'
    end

    def default_meta_description
      'Add repository and monitor pull requests. Track review time, number of reviews, merging speed. Get company-wide statistics
      to track with the rest of your peers. Discuss with teammates the data linked to pull requests'
    end
  end
end
