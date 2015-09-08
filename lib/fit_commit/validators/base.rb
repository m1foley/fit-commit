require "fit_commit/has_errors"

module FitCommit
  module Validators
    class Base
      include FitCommit::HasErrors

      attr_accessor :branch_name, :config
      def initialize(branch_name, config)
        self.branch_name = branch_name
        self.config = default_config.merge(config)
      end

      @all = []
      class << self
        attr_accessor :all
        def inherited(subclass)
          all << subclass
        end
      end

      def validate(lines)
        lines.each do |line|
          validate_line(line.lineno, line.text, branch_name)
        end
      end

      def validate_line(*)
        fail NotImplementedError, "Implement in subclass"
      end

      def default_config
        { "Enabled" => true }
      end

      def enabled?
        if config["Enabled"].is_a?(Array)
          config["Enabled"].any? { |pattern| matches_branch?(pattern) }
        else
          config["Enabled"]
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
