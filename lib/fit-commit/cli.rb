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
      if action_name == "install"
        FitCommit::Installer.new.install
      else
        warn "fit-commit v#{FitCommit::VERSION}"
        warn "Usage: fit-commit install"
        false
      end
    end
  end
end
