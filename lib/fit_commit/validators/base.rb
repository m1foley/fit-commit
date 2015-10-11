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
        if validation_methods.empty?
          fail NotImplementedError, "Implement a validation method in subclass."
        end

        validation_methods.each do |method|
          case method
          when :validate_line
            lines.each { |line| validate_line(line.lineno, line.text) }
          when :validate_lines
            validate_lines(lines)
          end
        end
      end

      def validation_methods
        [:validate_line, :validate_lines].select { |method| method_defined?(method) }
      end

      def method_defined?(method)
        self.class.instance_methods.include?(method)
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
