require "fit_commit/line"

module FitCommit
  class MessageParser
    GIT_VERBOSE_MARKER = "# ------------------------ >8 ------------------------"
    COMMENT_REGEX = /\A#/

    attr_accessor :message_path
    def initialize(message_path)
      self.message_path = message_path
    end

    def lines
      FitCommit::Line.from_text_array(relevant_lines)
    end

    private

    def relevant_lines
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
  end
end
