require "minitest/autorun"
require "fit-commit/validators/line_length"

describe FitCommit::Validators::LineLength do
  let(:validator) { FitCommit::Validators::LineLength.new(commit_lines, branch_name) }
  let(:commit_lines) { FitCommit::Line.from_array(commit_msg.split("\n")) }

  let(:branch_name) { "any" }

  describe "first line" do
    describe "first line is empty" do
      let(:commit_msg) { "\n\nbar" }
      it "has error" do
        validator.validate
        assert_equal 1, validator.errors[1].size
        assert_empty validator.warnings
      end
    end
    describe "first line is not empty" do
      let(:commit_msg) { "foo\n\nbar" }
      it "does not have error" do
        validator.validate
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
  describe "second line" do
    describe "second line is not empty" do
      let(:commit_msg) { "foo\nbar" }
      it "has error" do
        validator.validate
        assert_equal 1, validator.errors[2].size
        assert_empty validator.warnings
      end
    end
    describe "second line is empty" do
      let(:commit_msg) { "foo\n\nbar" }
      it "does not have error" do
        validator.validate
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
    describe "second line is not present" do
      let(:commit_msg) { "foo" }
      it "does not have error" do
        validator.validate
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
end
