require "fit-commit/runner"

module FitCommit
  def self.run
    runner.run || exit(1)
  end

  private

  def self.runner
    FitCommit::Runner.new(message_path, branch_name)
  end

  def self.message_path
    ENV.fetch("COMMIT_MESSAGE_PATH")
  end

  def self.branch_name
    `git name-rev --name-only HEAD`.strip
  end
end
