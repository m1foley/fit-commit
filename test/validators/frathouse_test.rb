require "minitest/autorun"
require "fit-commit/validators/frathouse"

describe FitCommit::Validators::Frathouse do
  let(:validator) { FitCommit::Validators::Frathouse.new(commit_lines, branch_name) }
  let(:commit_lines) { FitCommit::Line.from_array([commit_msg]) }

  describe "master branch" do
    let(:branch_name) { "master" }
    describe "contains swear word" do
      let(:commit_msg) { "fucking foo" }
      it "has error" do
        validator.validate
        refute_empty validator.errors
        refute_empty validator.errors[1]
        assert_empty validator.warnings
      end
    end
    describe "does not contain swear words" do
      let(:commit_msg) { "foo" }
      it "does not have errors/warnings" do
        validator.validate
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
  describe "not master branch" do
    let(:branch_name) { "notmaster" }
    describe "contains swear word" do
      let(:commit_msg) { "fucking foo" }
      it "does not have errors/warnings" do
        validator.validate
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
end
