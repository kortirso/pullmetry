# frozen_string_literal: true

module Import
  module Concerns
    module CommentParseable
      COMMENT_MATCH_REGEXP = /\*\*(.*)\*\*\:(.*)/

      private

      def parse_comment_body(value)
        return unless value
        return if COMMENT_MATCH_REGEXP.match(value).nil?

        header = value[/\*\*(.*)\*\*/, 1] # extract data between **...**
        {
          title: header.split.first,
          subject: value[/\*\*:(.*)/, 1].strip, # extract data after **:...
          decorations: header[/\((.*)\)/, 1]&.split(',')
        }
      end
    end
  end
end
