require "fit_commit/has_errors"

module FitCommit
  module Validators
    class Base
      include FitCommit::HasErrors

      attr_accessor :branch_name, :config
      def initialize(branch_name, config)
        self.branch_name = branch_name
        self.config = config
      end

      @all = []
      class << self
        attr_accessor :all
        def inherited(subclass)
          all << subclass
        end
      end

      def validate(lines)
        lines.each { |line| validate_line(line.lineno, line.text) }
      end

      def validate_line(*)
        fail NotImplementedError, "Implement in subclass"
      end

      def enabled?
        enabled_val = config.fetch("Enabled")
        if enabled_val.is_a?(Array)
          enabled_val.any? { |pattern| matches_branch?(pattern) }
        else
          enabled_val
        end
      end

      def matches_branch?(pattern)
        if pattern.is_a?(Regexp)
          pattern =~ branch_name
        else
          pattern == branch_name
        end
      end
    end
  end
end
