require "fit-commit/has_errors"
require "fit-commit/line"

module FitCommit
  class Runner
    include FitCommit::HasErrors

    def run
      exit(0) if empty_commit?

      run_all_validators

      if [errors, warnings].any? { |e| !e.empty? }
        unless errors.empty?
          $stdout.puts lines
          $stdout.print "\n"
        end

        (errors.keys | warnings.keys).sort.each do |lineno|
          errors[lineno].each do |error|
            $stdout.puts "#{lineno}: Error: #{error}"
          end
          warnings[lineno].each do |warning|
            $stdout.puts "#{lineno}: Warning: #{warning}"
          end
        end

        unless errors.empty?
          $stdout.print "\nForce commit? [y/n] "
          exit(1) unless $stdin.gets =~ /y/i
        end

        $stdout.print "\n"
      end
    rescue Interrupt # Ctrl-c
      exit(1)
    end

    private

    def run_all_validators
      Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }
      FitCommit::Validators::Base.all.each do |validator_class|
        validator = validator_class.new(lines, branch_name)
        validator.validate
        merge_errors(validator.errors)
        merge_warnings(validator.warnings)
      end
    end

    def lines
      @lines ||= File.open(message_path, "r").read.lines.map(&:chomp).
        reject(&method(:comment?)).
        map.with_index(1) { |text, lineno| FitCommit::Line.new(lineno, text) }
    end

    def message_path
      ENV.fetch("MESSAGE_PATH")
    end

    def comment?(text)
      text =~ /\A#/
    end

    def empty_commit?
      lines.all?(&:empty?)
    end

    def branch_name
      @branch_name ||= `git branch | grep '^\*' | cut -b3-`.strip
    end
  end
end
