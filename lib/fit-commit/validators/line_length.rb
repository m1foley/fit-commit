require "fit-commit/validators/base"

module FitCommit
  module Validators
    class LineLength < Base
      FIRST_LINE_MAX_LENGTH = 50
      LINE_MAX_LENGTH = 72

      def validate_line(lineno, text, _branch_name)
        if lineno == 1 && text.empty?
          add_error(lineno, "First line cannot be blank.")
        elsif lineno == 2 && !text.empty?
          add_error(lineno, "Second line must be blank.")
        elsif line_too_long?(text)
          add_error(lineno, format("Lines should be <= %i chars. (%i)",
            LINE_MAX_LENGTH, text.length))
        elsif lineno == 1 && text.length > FIRST_LINE_MAX_LENGTH
          add_warning(lineno, format("First line should be <= %i chars. (%i)",
            FIRST_LINE_MAX_LENGTH, text.length))
        end
      end

      def line_too_long?(text)
        text.length > 72 && !contains_url?(text)
      end

      def contains_url?(text)
        text =~ %r{[a-z]+://}
      end
    end
  end
end
