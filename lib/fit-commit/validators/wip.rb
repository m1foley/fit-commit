require "fit-commit/validators/base"

module FitCommit
  module Validators
    class Wip < Base
      def validate_line(lineno, text, branch_name)
        if lineno == 1 && branch_name == "master" &&
            text.split.any? { |word| word == "WIP" }
          add_error(lineno, "Do not commit WIPs to master.")
        end
      end
    end
  end
end
