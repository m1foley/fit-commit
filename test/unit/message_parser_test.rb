require "minitest/autorun"
require "fit_commit/message_parser"

describe FitCommit::MessageParser do
  after do
    commit_msg_file.unlink
  end

  let(:commit_msg_file) do
    Tempfile.new("test-commit-msg").tap do |f|
      f.write(commit_msg)
      f.close
    end
  end

  let(:lines) do
    FitCommit::MessageParser.new(commit_msg_file.path).lines
  end

  describe "empty commit msg" do
    let(:commit_msg) { "" }
    it "returns empty array" do
      assert_equal [], lines
    end
  end

  describe "commit msg consists of all comments" do
    let(:commit_msg) { "#\n#hi\n#yo\n#" }
    it "returns empty array" do
      assert_equal [], lines
    end
  end

  describe "commit msg is one line" do
    let(:commit_msg) { "foo" }
    it "parses text" do
      assert_equal 1, lines.size
      assert_equal [1], lines.map(&:lineno)
      assert_equal ["foo"], lines.map(&:text)
    end
  end

  describe "commit msg is one line plus comments" do
    let(:commit_msg) { "foo\n#hi\n#yo\n#" }
    it "parses text and ignores comments" do
      assert_equal 1, lines.size
      assert_equal [1], lines.map(&:lineno)
      assert_equal ["foo"], lines.map(&:text)
    end
  end

  describe "multi-line commit msg" do
    let(:commit_msg) { "a\n\nb\n#" }
    it "parses text and ignores comments" do
      assert_equal 3, lines.size
      assert_equal [1, 2, 3], lines.map(&:lineno)
      assert_equal ["a", "", "b"], lines.map(&:text)
    end
  end

  describe "commit msg in verbose format" do
    let(:commit_msg) do
      ["foo", "", "#",
        "# ------------------------ >8 ------------------------",
        "this difftext should be ignored."
      ].join("\n")
    end
    it "ignores text after verbose marker" do
      assert_equal 2, lines.size
      assert_equal [1, 2], lines.map(&:lineno)
      assert_equal ["foo", ""], lines.map(&:text)
    end
  end
end
