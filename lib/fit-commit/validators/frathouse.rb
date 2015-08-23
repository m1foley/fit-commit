require "fit-commit/validators/base"

module FitCommit
  module Validators
    class Frathouse < Base
      def validate_line(lineno, text, branch_name)
        if branch_name == "master" && frat_house?(text)
          add_error(lineno, "No frat house commit messages in master.")
        end
      end

      # TODO use the swearjar gem
      def frat_house?(text)
        text =~ /fuck(ing)?/i
      end
    end
  end
end
