#!/usr/bin/env ruby
# Encoding: utf-8

module FitCommit
  module HasErrors
    attr_writer :errors, :warnings

    def errors
      @errors ||= Hash.new([])
    end

    def warnings
      @warnings ||= Hash.new([])
    end

    def add_error(lineno, message)
      errors[lineno] += [message]
    end

    def add_warning(lineno, message)
      warnings[lineno] += [message]
    end

    def merge_errors(other_errors)
      merge_hashes(errors, other_errors)
    end

    def merge_warnings(other_warnings)
      merge_hashes(warnings, other_warnings)
    end

    def merge_hashes(error_hash, other_hash)
      error_hash.merge!(other_hash) do |_lineno, messages, other_messages|
        messages + other_messages
      end
    end
  end

  class CLI
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

    def lines
      @lines ||= File.open(ARGV[0], "r").read.lines.map(&:chomp).
        reject(&method(:comment?)).
        map.with_index(1) { |text, lineno| FitCommit::Line.new(lineno, text) }
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

    def run_all_validators
      FitCommit::Validators::Validator.all.each do |validator_class|
        validator = validator_class.new(lines, branch_name)
        validator.validate
        merge_errors(validator.errors)
        merge_warnings(validator.warnings)
      end
    end
  end

  class Line
    attr_accessor :lineno, :text
    def initialize(lineno, text)
      self.lineno = lineno
      self.text = text
    end

    def to_s
      text
    end

    def empty?
      text.empty?
    end
  end

  module Validators
    class Validator
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

    class LineLength < Validator
      FIRST_LINE_MAX_LENGTH = 50
      LINE_MAX_LENGTH = 72

      def validate_line(lineno, text, _branch_name)
        if lineno == 1 && text.empty?
          add_error(lineno, "First line cannot be blank.")
        elsif lineno == 2 && !text.empty?
          add_error(lineno, "Second line must be blank.")
        elsif line_too_long?(text)
          add_error(lineno, format("Lines should be <= %i chars. (%i)",
            LINE_MAX_LENGTH, text.length))
        elsif lineno == 1 && text.length > FIRST_LINE_MAX_LENGTH
          add_warning(lineno, format("First line should be <= %i chars. (%i)",
            FIRST_LINE_MAX_LENGTH, text.length))
        end
      end

      def line_too_long?(text)
        text.length > 72 && !contains_url?(text)
      end

      def contains_url?(text)
        text =~ %r{[a-z]+://}
      end
    end

    class Tense < Validator
      VERB_BLACKLIST = %w(
        adds       adding       added
        allows     allowing     allowed
        amends     amending     amended
        bumps      bumping      bumped
        calculates calculating  calculated
        changes    changing     changed
        cleans     cleaning     cleaned
        commits    committing   committed
        corrects   correcting   corrected
        creates    creating     created
        darkens    darkening    darkened
        disables   disabling    disabled
        displays   displaying   displayed
        drys       drying       dryed
        ends       ending       ended
        enforces   enforcing    enforced
        enqueues   enqueuing    enqueued
        extracts   extracting   extracted
        finishes   finishing    finished
        fixes      fixing       fixed
        formats    formatting   formatted
        guards     guarding     guarded
        handles    handling     handled
        hides      hiding       hid
        increases  increasing   increased
        ignores    ignoring     ignored
        implements implementing implemented
        improves   improving    improved
        keeps      keeping      kept
        kills      killing      killed
        makes      making       made
        merges     merging      merged
        moves      moving       moved
        permits    permitting   permitted
        prevents   preventing   prevented
        pushes     pushing      pushed
        rebases    rebasing     rebased
        refactors  refactoring  refactored
        removes    removing     removed
        renames    renaming     renamed
        reorders   reordering   reordered
        requires   requiring    required
        restores   restoring    restored
        sends      sending      sent
        sets       setting
        separates  separating   separated
        shows      showing      showed
        skips      skipping     skipped
        sorts      sorting
        speeds     speeding     sped
        starts     starting     started
        supports   supporting   supported
        takes      taking       took
        tests      testing      tested
        truncates  truncating   truncated
        updates    updating     updated
        uses       using        used
      )

      def validate_line(lineno, text, _branch_name)
        if lineno == 1 && wrong_tense?(text)
          add_error(lineno, "Message must use present imperative tense.")
        end
      end

      def wrong_tense?(text)
        first_word = text.split.first(2).detect { |w| w =~ /\A\w/ }
        first_word && VERB_BLACKLIST.include?(first_word.downcase)
      end
    end

    class Wip < Validator
      def validate_line(lineno, text, branch_name)
        if lineno == 1 && text.split.any? { |word| word == "WIP" } &&
           branch_name == "master"
          add_error(lineno, "Do not commit WIPs to master.")
        end
      end
    end
  end
end

FitCommit::CLI.new.run
