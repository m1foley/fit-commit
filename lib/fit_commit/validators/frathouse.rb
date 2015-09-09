require "fit_commit/validators/base"
require "swearjar"

module FitCommit
  module Validators
    class Frathouse < Base
      def validate_line(lineno, text)
        if Swearjar.default.profane?(text)
          add_error(lineno, "No frat house commit messages in shared branches.")
        end
      end

      def default_config
        super.merge("Enabled" => ["master"])
      end
    end
  end
end
