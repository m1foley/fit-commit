require "fit_commit/validators/base"

module FitCommit
  module Validators
    class LineLength < Base
      MERGE_COMMIT = /\AMerge branch '[^']+' into ./
      URL = %r{[a-z]+://}

      def validate_line(lineno, text)
        if lineno == 1
          if text.empty?
            add_error(lineno, "Subject line cannot be blank.")
          elsif text !~ MERGE_COMMIT
            if text.length > max_line_length
              add_error(lineno, format("Lines should be <= %i chars. (%i)",
                max_line_length, text.length))
            elsif text.length > subject_warn_length
              add_warning(lineno, format("Subject line should be <= %i chars. (%i)",
                subject_warn_length, text.length))
            end
          end
        elsif lineno == 2
          unless text.empty?
            add_error(lineno, "Second line must be blank.")
          end
        elsif text.length > max_line_length && !(allow_long_urls? && text =~ URL)
          add_error(lineno, format("Lines should be <= %i chars. (%i)",
            max_line_length, text.length))
        end
      end

      def max_line_length
        config.fetch("MaxLineLength")
      end

      def subject_warn_length
        config.fetch("SubjectWarnLength")
      end

      def allow_long_urls?
        config.fetch("AllowLongUrls")
      end
    end
  end
end
