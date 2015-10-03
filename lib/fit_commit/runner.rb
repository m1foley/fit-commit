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
      allow_commit = retry_on_user_edit do
        return EXIT_CODE_ALLOW_COMMIT if empty_commit?
        run_validators
        return EXIT_CODE_ALLOW_COMMIT if [errors, warnings].all?(&:empty?)
        print_results
        errors.empty? || ask_force_commit
      end

      if allow_commit
        stderr.print "\n"
        EXIT_CODE_ALLOW_COMMIT
      else
        EXIT_CODE_REJECT_COMMIT
      end
    rescue Interrupt # Ctrl-c
      EXIT_CODE_REJECT_COMMIT
    end

    private

    StartOverOnEditException = Class.new(StandardError)

    def retry_on_user_edit
      yield
    rescue StartOverOnEditException
      clear_lines
      clear_errors
      clear_warnings
      edit_message && retry
    end

    def ask_force_commit
      return unless interactive?
      stderr.print "\nForce commit? [y/n/e] "
      input = stdin.gets
      fail StartOverOnEditException if input =~ /e/i
      input =~ /y/i
    end

    def interactive?
      stdin.tty?
    end

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

    def clear_lines
      @lines = nil
    end

    def empty_commit?
      lines.all?(&:empty?)
    end

    def edit_message
      system(editor, message_path)
    end

    DEFAULT_EDITOR = "vim"

    def editor
      editor = ENV["EDITOR"]
      editor = DEFAULT_EDITOR unless editor && editor != "none"
      editor
    end
  end
end
