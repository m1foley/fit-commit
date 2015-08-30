require "fit_commit/installer"
require "fit_commit/version"

module FitCommit
  class Cli
    EXIT_CODE_SUCCESS = 0
    EXIT_CODE_FAILURE = 1

    attr_accessor :args
    def initialize(*args)
      self.args = args
    end

    def execute
      action_name = args.shift
      case action_name
      when "install"
        FitCommit::Installer.new.install
        EXIT_CODE_SUCCESS
      when "uninstall"
        FitCommit::Installer.new.uninstall
        EXIT_CODE_SUCCESS
      else
        print_help
        EXIT_CODE_FAILURE
      end
    end

    private

    def print_help
      warn "fit-commit v#{FitCommit::VERSION}"
      warn "Usage: fit-commit install"
      warn "Usage: fit-commit uninstall"
    end
  end
end
