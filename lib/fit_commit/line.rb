# Represents a line from the commit
module FitCommit
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

    def self.from_text_array(text_array)
      text_array.map.with_index(1) { |text, lineno| new(lineno, text) }
    end
  end
end
