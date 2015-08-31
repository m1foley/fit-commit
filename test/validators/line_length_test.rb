require "minitest/autorun"
require "fit_commit/validators/line_length"
require "fit_commit/line"

describe FitCommit::Validators::LineLength do
  let(:validator) { FitCommit::Validators::LineLength.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:config) { {} }
  let(:branch_name) { "any" }

  describe "first line" do
    describe "first line is empty" do
      let(:commit_msg) { "\n\nbar" }
      it "has error" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[1].size
        assert_empty validator.warnings
      end
    end
    describe "first line is not empty" do
      let(:commit_msg) { "foo\n\nbar" }
      it "does not have error" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
    describe "first line is over warning limit" do
      let(:commit_msg) do
        "x" * (FitCommit::Validators::LineLength::FIRST_LINE_MAX_LENGTH + 1)
      end
      it "has a warning" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_equal 1, validator.warnings[1].size
      end
    end
    describe "first line is over error limit" do
      let(:commit_msg) do
        "x" * (FitCommit::Validators::LineLength::LINE_MAX_LENGTH + 1)
      end
      it "has an error and no warning" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[1].size
        assert_empty validator.warnings
      end
    end
  end
  describe "second line" do
    describe "second line is not empty" do
      let(:commit_msg) { "foo\nbar" }
      it "has error" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[2].size
        assert_empty validator.warnings
      end
    end
    describe "second line is not empty and too long" do
      let(:commit_msg) do
        "foo\n" + ("x" * (FitCommit::Validators::LineLength::LINE_MAX_LENGTH + 1))
      end
      it "only mentions blank error" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[2].size
        assert_match(/must be blank/, validator.errors[2][0])
        assert_empty validator.warnings
      end
    end
    describe "second line is empty" do
      let(:commit_msg) { "foo\n\nbar" }
      it "does not have error" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
    describe "does not have a second line" do
      let(:commit_msg) { "foo" }
      it "does not have error" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
  describe "body text" do
    describe "line is over length limit" do
      let(:commit_msg) do
        "foo\n\n" + ("x" * (FitCommit::Validators::LineLength::LINE_MAX_LENGTH + 1))
      end
      it "has error" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[3].size
        assert_empty validator.warnings
      end
    end
    describe "line is equal to length limit" do
      let(:commit_msg) do
        "foo\n\n" + ("x" * FitCommit::Validators::LineLength::LINE_MAX_LENGTH)
      end
      it "does not have error" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
end
