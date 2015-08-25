# Mixin for adding errors & warnings
module FitCommit
  module HasErrors
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

    private

    def merge_hashes(error_hash, other_hash)
      error_hash.merge!(other_hash) do |_lineno, messages, other_messages|
        messages + other_messages
      end
    end
  end
end
