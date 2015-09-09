require File.expand_path "../validator_helper.rb", __FILE__
require "fit_commit/validators/wip"
require "fit_commit/line"

describe FitCommit::Validators::Wip do
  let(:validator) { FitCommit::Validators::Wip.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:default_config) { default_config_for("Validators/Wip") }
  let(:config) { default_config }
  let(:branch_name) { "any" }

  describe "contains WIP" do
    let(:commit_msg) { "WIP foo" }
    it "has error" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end
  describe "does not contain WIP" do
    let(:commit_msg) { "foo" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
