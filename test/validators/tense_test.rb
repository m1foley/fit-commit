require "minitest/autorun"
require "fit_commit/validators/tense"
require "fit_commit/line"

describe FitCommit::Validators::Tense do
  let(:validator) { FitCommit::Validators::Tense.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:config) { {} }
  let(:branch_name) { "any" }

  describe "uses incorrect tense on first line" do
    let(:commit_msg) { "Changed something" }
    it "has error" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end

  describe "uses incorrect tense on first line" do
    let(:commit_msg) { "[#ticketno] Changed something" }
    it "has error" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end

  describe "has incorrect tense after the first word" do
    let(:commit_msg) { "Document fixes to bug" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end

  describe "uses incorrect tense on a line other than first line" do
    let(:commit_msg) { "Fix bug\n\nChanged something" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
