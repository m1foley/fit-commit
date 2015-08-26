require "fit-commit/validators/base"
require "swearjar"

module FitCommit
  module Validators
    class Frathouse < Base
      def validate_line(lineno, text, branch_name)
        if branch_name == "master" && Swearjar.default.profane?(text)
          add_error(lineno, "No frat house commit messages in master.")
        end
      end
    end
  end
end
