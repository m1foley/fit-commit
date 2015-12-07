require File.expand_path "../validator_helper.rb", __FILE__
require "fit_commit/validators/capitalize_subject"
require "fit_commit/line"

describe FitCommit::Validators::CapitalizeSubject do
  let(:validator) { FitCommit::Validators::CapitalizeSubject.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:default_config) { default_config_for("Validators/CapitalizeSubject") }
  let(:config) { default_config }
  let(:branch_name) { "any" }

  describe "subject is not capitalized" do
    let(:commit_msg) { "foo bar" }
    it "has error" do
      validator.validate(commit_lines)
      assert_equal 1, validator.errors[1].size
      assert_empty validator.warnings
    end
  end
  describe "subject is fixup commit" do
    let(:commit_msg) { "fixup! foo bar" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
  describe "subject is squash commit" do
    let(:commit_msg) { "squash! foo bar" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
  describe "subject is capitalized" do
    let(:commit_msg) { "Foo bar" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
  describe "subject is capitalized but body is not" do
    let(:commit_msg) { "Foo bar\n\nbaz" }
    it "does not have errors/warnings" do
      validator.validate(commit_lines)
      assert_empty validator.errors
      assert_empty validator.warnings
    end
  end
end
