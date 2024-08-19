# frozen_string_literal: true

module Authkeeper
  class Engine < ::Rails::Engine
    isolate_namespace Authkeeper
  end
end
