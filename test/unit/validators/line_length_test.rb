require File.expand_path "../validator_helper.rb", __FILE__
require "fit_commit/validators/line_length"
require "fit_commit/line"

describe FitCommit::Validators::LineLength do
  let(:validator) { FitCommit::Validators::LineLength.new(branch_name, config) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }
  let(:default_config) { default_config_for("Validators/LineLength") }
  let(:config) { default_config }
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
      let(:commit_msg) { "x" * 51 }
      it "has a warning" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_equal 1, validator.warnings[1].size
      end
    end
    describe "first line is over error limit" do
      let(:commit_msg) { "x" * 73 }
      it "has an error and no warning" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[1].size
        assert_empty validator.warnings
      end
    end
    describe "SummaryWarnLength modified in config" do
      let(:config) { default_config.merge("SummaryWarnLength" => 5) }
      describe "first line is over modified warning limit" do
        let(:commit_msg) { "x" * 6 }
        it "has a warning" do
          validator.validate(commit_lines)
          assert_empty validator.errors
          assert_equal 1, validator.warnings[1].size
        end
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
      let(:commit_msg) { "foo\n" + ("x" * 73) }
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
      let(:commit_msg) { "foo\n\n" + ("x" * 73) }
      it "has error" do
        validator.validate(commit_lines)
        assert_equal 1, validator.errors[3].size
        assert_empty validator.warnings
      end
    end
    describe "line is over length limit and has an URL" do
      let(:commit_msg) { "foo\n\nhttps://" + ("x" * 100) }
      it "does not have error" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_empty validator.warnings
      end
      describe "AllowLongUrls modified in config" do
        let(:config) { default_config.merge("AllowLongUrls" => false) }
        it "has error" do
          validator.validate(commit_lines)
          assert_equal 1, validator.errors[3].size
          assert_empty validator.warnings
        end
      end
    end
    describe "line is equal to length limit" do
      let(:commit_msg) { "foo\n\n" + ("x" * 72) }
      it "does not have error" do
        validator.validate(commit_lines)
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
    describe "MaxLineLength modified in config" do
      let(:config) { default_config.merge("MaxLineLength" => 5) }
      describe "line is over modified limit" do
        let(:commit_msg) { "foo\n\n" + ("x" * 6) }
        it "has error" do
          validator.validate(commit_lines)
          assert_equal 1, validator.errors[3].size
          assert_empty validator.warnings
        end
      end
    end
  end
end
