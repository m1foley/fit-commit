require "minitest/autorun"
require "fit-commit/validators/tense"

describe FitCommit::Validators::Tense do
  let(:validator) { FitCommit::Validators::Tense.new(commit_lines, branch_name) }
  let(:commit_lines) { FitCommit::Line.from_array(commit_msg.split("\n")) }

  let(:branch_name) { "anybranch" }

  describe "uses incorrect tense on first line" do
    let(:commit_msg) { "Changed something\nhi" }
    it "has error" do
      validator.validate
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end

  describe "uses incorrect tense on a line other than first line" do
    let(:commit_msg) { "hi\nChanged something" }
    it "does not have errors/warnings" do
      validator.validate
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
