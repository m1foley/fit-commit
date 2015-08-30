require "fit-commit/installer"
require "fit-commit/version"

module FitCommit
  class Cli
    attr_accessor :args
    def initialize(*args)
      self.args = args
    end

    def execute
      action_name = args.shift
      case action_name
      when "install"
        FitCommit::Installer.new.install
      when "uninstall"
        FitCommit::Installer.new.uninstall
      else
        warn "fit-commit v#{FitCommit::VERSION}"
        warn "Usage: fit-commit install"
        warn "Usage: fit-commit uninstall"
        false
      end
    end
  end
end
