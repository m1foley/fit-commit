require "minitest/autorun"
require "fit_commit/validators/wip"

describe FitCommit::Validators::Wip do
  let(:validator) { FitCommit::Validators::Wip.new(commit_lines, branch_name) }
  let(:commit_lines) { FitCommit::Line.from_text_array(commit_msg.split("\n")) }

  describe "master branch" do
    let(:branch_name) { "master" }
    describe "contains WIP" do
      let(:commit_msg) { "WIP foo" }
      it "has error" do
        validator.validate
        assert_equal 1, validator.errors[1].size
        assert_empty validator.warnings
      end
    end
    describe "does not contain WIP" do
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
    describe "contains WIP" do
      let(:commit_msg) { "WIP foo" }
      it "does not have errors/warnings" do
        validator.validate
        assert_empty validator.errors
        assert_empty validator.warnings
      end
    end
  end
end
