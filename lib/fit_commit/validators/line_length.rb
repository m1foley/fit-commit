require "fit_commit/validators/base"

module FitCommit
  module Validators
    class LineLength < Base
      def validate_line(lineno, text)
        if lineno == 1 && text.empty?
          add_error(lineno, "First line cannot be blank.")
        elsif lineno == 2 && !text.empty?
          add_error(lineno, "Second line must be blank.")
        elsif line_too_long?(text)
          add_error(lineno, format("Lines should be <= %i chars. (%i)",
            max_line_length, text.length))
        elsif lineno == 1 && text.length > summary_warn_length
          add_warning(lineno, format("First line should be <= %i chars. (%i)",
            summary_warn_length, text.length))
        end
      end

      def line_too_long?(text)
        text.length > max_line_length && !(allow_long_urls? && contains_url?(text))
      end

      def contains_url?(text)
        text =~ %r{[a-z]+://}
      end

      def max_line_length
        config["MaxLineLength"]
      end

      def summary_warn_length
        config["SummaryWarnLength"]
      end

      def allow_long_urls?
        config["AllowLongUrls"]
      end

      def default_config
        super.merge(
          "Enabled" => true,
          "MaxLineLength" => 72,
          "SummaryWarnLength" => 50,
          "AllowLongUrls" => true
        )
      end
    end
  end
end
