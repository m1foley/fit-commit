require "fit-commit/has_errors"
require "fit-commit/line"

module FitCommit
  class Runner
    include FitCommit::HasErrors

    attr_accessor :message_path, :branch_name, :stdout, :stdin
    def initialize(message_path, branch_name, stdout = $stdout, stdin = $stdin)
      self.message_path = message_path
      self.branch_name = branch_name
      self.stdout = stdout
      self.stdin = stdin
    end

    def run
      return true if empty_commit?
      run_validators
      return true if [errors, warnings].all?(&:empty?)
      print_results

      allow_commit = errors.empty?
      unless allow_commit
        stdout.print "\nForce commit? [y/n] "
        return false unless stdin.gets =~ /y/i
        allow_commit = true
      end

      stdout.print "\n"
      allow_commit
    rescue Interrupt # Ctrl-c
      false
    end

    private

    def run_validators
      Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }
      FitCommit::Validators::Base.all.each do |validator_class|
        validator = validator_class.new(lines, branch_name)
        validator.validate
        merge_errors(validator.errors)
        merge_warnings(validator.warnings)
      end
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

    def relevant_message_lines
      message_text.lines.map(&:chomp).reject(&method(:comment?))
    end

    def message_text
      File.open(message_path, "r").read
    end

    def comment?(text)
      text =~ /\A#/
    end

    def empty_commit?
      lines.all?(&:empty?)
    end
  end
end
