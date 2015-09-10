require "fit_commit/has_errors"
require "fit_commit/message_parser"
require "fit_commit/validator_loader"

module FitCommit
  class Runner
    include FitCommit::HasErrors

    EXIT_CODE_ALLOW_COMMIT  = 0
    EXIT_CODE_REJECT_COMMIT = 1

    attr_accessor :message_path, :branch_name, :stderr, :stdin
    def initialize(message_path, branch_name, stderr = $stderr, stdin = $stdin)
      self.message_path = message_path
      self.branch_name = branch_name
      self.stderr = stderr
      self.stdin = stdin
    end

    def run
      return EXIT_CODE_ALLOW_COMMIT if empty_commit?
      run_validators
      return EXIT_CODE_ALLOW_COMMIT if [errors, warnings].all?(&:empty?)
      print_results

      allow_commit = errors.empty?
      unless allow_commit
        stderr.print "\nForce commit? [y/n] "
        return EXIT_CODE_REJECT_COMMIT unless stdin.gets =~ /y/i
        allow_commit = true
      end

      stderr.print "\n"
      allow_commit ? EXIT_CODE_ALLOW_COMMIT : EXIT_CODE_REJECT_COMMIT
    rescue Interrupt # Ctrl-c
      EXIT_CODE_REJECT_COMMIT
    end

    private

    def run_validators
      validators.each do |validator|
        validator.validate(lines)
        merge_errors(validator.errors)
        merge_warnings(validator.warnings)
      end
    end

    def validators
      FitCommit::ValidatorLoader.new(branch_name).validators
    end

    def print_results
      unless errors.empty?
        stderr.puts lines
        stderr.print "\n"
      end

      (errors.keys | warnings.keys).sort.each do |lineno|
        errors[lineno].each do |error|
          stderr.puts "#{lineno}: Error: #{error}"
        end
        warnings[lineno].each do |warning|
          stderr.puts "#{lineno}: Warning: #{warning}"
        end
      end
    end

    def lines
      @lines ||= FitCommit::MessageParser.new(message_path).lines
    end

    def empty_commit?
      lines.all?(&:empty?)
    end
  end
end
