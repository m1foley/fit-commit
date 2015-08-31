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
        config["Enabled"]
      end
    end
  end
end
