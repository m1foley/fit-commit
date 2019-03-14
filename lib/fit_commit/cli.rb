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
      action_name = in_git_repo? ? args.shift : :fail_git_repo
      action_name = :help unless action_name && respond_to?(action_name, :include_private)
      send(action_name)
    end

    private

    def help
      $stderr.puts "fit-commit v#{FitCommit::VERSION}"
      $stderr.puts "Usage: fit-commit install"
      $stderr.puts "Usage: fit-commit uninstall"
      EXIT_CODE_SUCCESS
    end

    def install
      FitCommit::Installer.new.install
      EXIT_CODE_SUCCESS
    end

    def uninstall
      FitCommit::Installer.new.uninstall
      EXIT_CODE_SUCCESS
    end

    def in_git_repo?
      File.exist?(".git")
    end

    def fail_git_repo
      $stderr.puts "fit-commit: .git directory not found. Please run from your Git repository root."
      EXIT_CODE_FAILURE
    end
  end
end
