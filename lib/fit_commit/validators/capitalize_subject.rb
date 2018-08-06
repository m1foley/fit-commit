require "fit_commit/validators/base"

module FitCommit
  module Validators
    class CapitalizeSubject < Base
      MESSAGE = "Begin all subject lines with a capital letter."
      SINGLE_WORD = /\A\w+\z/
      AUTOSQUASH = /\A(fixup|squash)! /

      def validate(lines)
        if lines[0].text =~ /\A[[:lower:]]/ && lines[0].text !~ AUTOSQUASH
          if ignore_on_wiplikes? && wiplike?(lines)
            add_warning(1, MESSAGE)
          else
            add_error(1, MESSAGE)
          end
        end
      end

      private

      def wiplike?(lines)
        lines[0].text =~ SINGLE_WORD && lines[1..-1].all?(&:empty?)
      end

      def ignore_on_wiplikes?
        config.fetch("WarnOnWiplikes")
      end
    end
  end
end
