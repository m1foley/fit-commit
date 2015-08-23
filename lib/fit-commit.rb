require 'fit-commit/runner'

module FitCommit
  def self.run
    FitCommit::Runner.new.run
  end
end
