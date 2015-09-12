require File.expand_path "../validator_helper.rb", __FILE__
require "fit_commit/validators/frathouse"
require "fit_commit/line"

describe FitCommit::Validators::Frathouse do
  let(:validator) { FitCommit::Validators::Frathouse.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:default_config) { default_config_for("Validators/Frathouse") }
  let(:config) { default_config }
  let(:branch_name) { "any" }

  describe "contains swear word" do
    let(:commit_msg) { "fucking foobar" }
    it "has error" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end
  describe "contains swear words on multiple lines" do
    let(:commit_msg) { "damn\n\nIE7 is fucking bullshit!" }
    it "has 1 error per line" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_equal 1, validator.errors[3].size
      assert_empty validator.warnings
    end
  end
  describe "does not contain swear words" do
    let(:commit_msg) { "foo" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
