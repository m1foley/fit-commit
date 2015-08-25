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
    ENV.fetch("MESSAGE_PATH")
  end

  def self.branch_name
    `git branch | grep '^\*' | cut -b3-`.strip
  end
end
