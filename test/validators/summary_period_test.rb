require "minitest/autorun"
require "fit-commit/validators/summary_period"

describe FitCommit::Validators::SummaryPeriod do
  let(:validator) { FitCommit::Validators::SummaryPeriod.new(commit_lines, branch_name) }
  let(:commit_lines) { FitCommit::Line.from_array(commit_msg.split("\n")) }
  let(:branch_name) { "any" }

  describe "summary ends with period" do
    let(:commit_msg) { "foo bar." }
    it "has error" do
      validator.validate
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end
  describe "summary does not end with period" do
    let(:commit_msg) { "foo bar\n\nhi." }
    it "does not have errors/warnings" do
      validator.validate
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
