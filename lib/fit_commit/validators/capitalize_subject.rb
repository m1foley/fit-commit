require "fit_commit/validators/base"

module FitCommit
  module Validators
    class CapitalizeSubject < Base
      AUTOSQUASH = /\A(fixup|squash)! /

      def validate_line(lineno, text)
        if lineno == 1 && text[0] =~ /[[:lower:]]/ && text !~ AUTOSQUASH
          add_error(lineno, "Begin all subject lines with a capital letter.")
        end
      end
    end
  end
end
