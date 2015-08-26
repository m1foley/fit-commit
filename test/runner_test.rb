require "minitest/autorun"
require "fit-commit/runner"

describe FitCommit::Runner do
  after do
    commit_msg_file.unlink
  end

  def call_runner
    allow_commit = runner.run
    stdout.rewind
    allow_commit
  end

  let(:commit_msg_file) do
    Tempfile.new("test-commit-msg").tap do |f|
      f.write(commit_msg)
      f.close
    end
  end
  let(:stdout) { StringIO.new }
  let(:stdin) { StringIO.new }
  let(:branch_name) { "any" }
  let(:runner) do
    FitCommit::Runner.new(commit_msg_file.path, branch_name, stdout, stdin)
  end

  describe "empty commit msg" do
    let(:commit_msg) { "" }
    it "returns truthy value without printing to stdout" do
      assert call_runner
      assert stdout.read.empty?
    end
  end

  describe "commit msg consists of all comments" do
    let(:commit_msg) { "\n#hi\n#yo" }
    it "returns truthy value without printing to stdout" do
      assert call_runner
      assert stdout.read.empty?
    end
  end

  describe "commit msg is present but no errors" do
    let(:commit_msg) { "hello\n\nhi\n#" }
    it "returns truthy value without printing to stdout" do
      assert call_runner
      assert stdout.read.empty?
    end
  end

  describe "commit msg contains errors" do
    let(:commit_msg) { "foo.\nbar" }

    def assert_error_output
      stdout_lines = stdout.read.lines.map(&:chomp)
      assert_equal 7, stdout_lines.size
      assert_equal commit_msg, stdout_lines[0..1].join("\n")
      assert_empty stdout_lines[2]
      assert_match(/\A1: Error: /, stdout_lines[3])
      assert_match(/\A2: Error: /, stdout_lines[4])
      assert_empty stdout_lines[5]
      assert_equal "Force commit? [y/n] ", stdout_lines[6]
    end

    describe "user does not force commit" do
      let(:stdin) { StringIO.new("n") }
      it "prints errors to stdout and returns falsey value" do
        assert !call_runner
        assert_error_output
      end
    end
    describe "user forces commit" do
      let(:stdin) { StringIO.new("y") }
      it "prints errors to stdout and returns truthy value" do
        assert call_runner
        assert_error_output
      end
    end
  end
end
