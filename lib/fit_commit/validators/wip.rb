require "fit_commit/validators/base"

module FitCommit
  module Validators
    class Wip < Base
      def validate_line(lineno, text)
        if lineno == 1 && text.split.any? { |word| word == "WIP" }
          add_error(lineno, "Do not commit WIPs to shared branches.")
        end
      end
    end
  end
end
