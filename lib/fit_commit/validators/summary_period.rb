require "fit_commit/validators/base"

module FitCommit
  module Validators
    class SummaryPeriod < Base
      def validate_line(lineno, text, branch_name)
        if lineno == 1 && text.end_with?(".")
          add_error(lineno, "Do not end your summary with a period.")
        end
      end
    end
  end
end
