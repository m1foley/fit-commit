require "fit-commit/has_errors"

module FitCommit
  module Validators
    class Base
      include FitCommit::HasErrors

      attr_accessor :lines, :branch_name
      def initialize(lines, branch_name)
        self.lines = lines
        self.branch_name = branch_name
      end

      @all = []
      class << self
        attr_accessor :all
        def inherited(subclass)
          all << subclass
        end
      end

      def validate
        lines.each do |line|
          validate_line(line.lineno, line.text, branch_name)
        end
      end

      def validate_line(*)
        fail NotImplementedError, "Implement in subclass"
      end
    end
  end
end
