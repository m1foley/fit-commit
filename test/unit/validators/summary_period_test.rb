require File.expand_path "../validator_helper.rb", __FILE__
require "fit_commit/validators/summary_period"
require "fit_commit/line"

describe FitCommit::Validators::SummaryPeriod do
  let(:validator) { FitCommit::Validators::SummaryPeriod.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:default_config) { default_config_for("Validators/SummaryPeriod") }
  let(:config) { default_config }
  let(:branch_name) { "any" }

  describe "summary ends with period" do
    let(:commit_msg) { "foo bar." }
    it "has error" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end
  describe "summary does not end with period" do
    let(:commit_msg) { "foo bar\n\nhi." }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
