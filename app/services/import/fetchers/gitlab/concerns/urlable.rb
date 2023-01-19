# frozen_string_literal: true

module Import
  module Fetchers
    module Gitlab
      module Concerns
        module Urlable
          private

          def base_url(repository)
            url = URI(repository.link)
            "#{url.scheme}://#{url.host}"
          end
        end
      end
    end
  end
end
