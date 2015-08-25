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
    let(:commit_msg) { "foo\nbar" }
    it "returns falsey value and prints to stdout" do
      assert !call_runner
      assert !stdout.read.empty?
    end
  end
end
