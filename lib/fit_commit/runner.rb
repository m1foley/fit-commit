require "fit_commit/has_errors"
require "fit_commit/line"

module FitCommit
  class Runner
    include FitCommit::HasErrors

    EXIT_CODE_ALLOW_COMMIT  = 0
    EXIT_CODE_REJECT_COMMIT = 1

    attr_accessor :message_path, :branch_name, :stdout, :stdin
    def initialize(message_path, branch_name, stdout = $stdout, stdin = $stdin)
      self.message_path = message_path
      self.branch_name = branch_name
      self.stdout = stdout
      self.stdin = stdin
    end

    def run
      return EXIT_CODE_ALLOW_COMMIT if empty_commit?
      run_validators
      return EXIT_CODE_ALLOW_COMMIT if [errors, warnings].all?(&:empty?)
      print_results

      allow_commit = errors.empty?
      unless allow_commit
        stdout.print "\nForce commit? [y/n] "
        return EXIT_CODE_REJECT_COMMIT unless stdin.gets =~ /y/i
        allow_commit = true
      end

      stdout.print "\n"
      allow_commit ? EXIT_CODE_ALLOW_COMMIT : EXIT_CODE_REJECT_COMMIT
    rescue Interrupt # Ctrl-c
      EXIT_CODE_REJECT_COMMIT
    end

    private

    def run_validators
      validator_classes.each do |validator_class|
        validator = validator_class.new(lines, branch_name)
        validator.validate
        merge_errors(validator.errors)
        merge_warnings(validator.warnings)
      end
    end

    def validator_classes
      Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }
      FitCommit::Validators::Base.all
    end

    def print_results
      unless errors.empty?
        stdout.puts lines
        stdout.print "\n"
      end

      (errors.keys | warnings.keys).sort.each do |lineno|
        errors[lineno].each do |error|
          stdout.puts "#{lineno}: Error: #{error}"
        end
        warnings[lineno].each do |warning|
          stdout.puts "#{lineno}: Warning: #{warning}"
        end
      end
    end

    def lines
      @lines ||= FitCommit::Line.from_array(relevant_message_lines)
    end

    GIT_VERBOSE_MARKER = "# ------------------------ >8 ------------------------"
    COMMENT_REGEX = /\A#/

    def relevant_message_lines
      message_text.lines.each_with_object([]) do |line, relevant_lines|
        line.chomp!
        break relevant_lines if line == GIT_VERBOSE_MARKER
        next if line =~ COMMENT_REGEX
        relevant_lines << line.chomp
      end
    end

    def message_text
      File.read(message_path)
    end

    def empty_commit?
      lines.all?(&:empty?)
    end
  end
end
