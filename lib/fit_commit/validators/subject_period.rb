require "fit_commit/validators/base"

module FitCommit
  module Validators
    class SubjectPeriod < Base
      def validate_line(lineno, text)
        if lineno == 1 && text.end_with?(".")
          add_error(lineno, "Do not end your subject line with a period.")
        end
      end
    end
  end
end
