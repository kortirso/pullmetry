# frozen_string_literal: true

module Authkeeper
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
