require "minitest/autorun"
require "fit_commit/runner"

describe FitCommit::Runner do
  after do
    commit_msg_file.unlink
  end

  def call_runner
    exit_code = runner.run
    stderr.rewind
    exit_code
  end

  let(:commit_msg_file) do
    Tempfile.new("test-commit-msg").tap do |f|
      f.write(commit_msg)
      f.close
    end
  end
  let(:stderr) { StringIO.new }
  let(:stdin) { StringIO.new }
  let(:branch_name) { "any" }
  let(:runner) do
    FitCommit::Runner.new(commit_msg_file.path, branch_name, stderr, stdin)
  end

  describe "empty commit msg" do
    let(:commit_msg) { "" }
    it "allows commit without printing to stderr" do
      assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
      assert stderr.read.empty?
    end
  end

  describe "commit msg consists of all comments" do
    let(:commit_msg) { "\n#hi\n#yo\n#" }
    it "allows commit without printing to stderr" do
      assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
      assert stderr.read.empty?
    end
  end

  describe "commit msg is present but no errors" do
    let(:commit_msg) { "Hello\n\nhi\n#" }
    it "allows commit without printing to stderr" do
      assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
      assert stderr.read.empty?
    end
  end

  describe "commit msg in verbose format" do
    let(:commit_msg) do
      ["Foo", "", "#",
        "# ------------------------ >8 ------------------------",
        "this difftext should be ignored." * 3
      ].join("\n")
    end
    it "allows commit without printing to stderr" do
      assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
      assert stderr.read.empty?
    end
  end

  describe "commit msg contains errors" do
    let(:commit_msg) { "foo.\nbar" }

    def assert_error_output(interactive: true)
      stderr_lines = stderr.read.lines.map(&:chomp)
      expected_lines = interactive ? 8 : 6
      assert_equal expected_lines, stderr_lines.size
      assert_equal commit_msg, stderr_lines[0..1].join("\n")
      assert_empty stderr_lines[2]
      assert_match(/\A1: Error: /, stderr_lines[3])
      assert_match(/\A1: Error: /, stderr_lines[4])
      assert_match(/\A2: Error: /, stderr_lines[5])
      if interactive
        assert_empty stderr_lines[6]
        assert_equal "Force commit? [y/n] ", stderr_lines[7]
      end
    end

    def fake_tty(text)
      StringIO.new(text).tap do |stringio|
        def stringio.tty?
          true
        end
      end
    end

    describe "user does not force commit" do
      let(:stdin) { fake_tty("n") }
      it "prints errors to stderr and rejects commit" do
        assert_equal FitCommit::Runner::EXIT_CODE_REJECT_COMMIT, call_runner
        assert_error_output
      end
    end
    describe "user forces commit" do
      let(:stdin) { fake_tty("y") }
      it "prints errors to stderr and allows commit" do
        assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
        assert_error_output
      end
    end
    describe "TTY not available" do
      let(:stdin) { StringIO.new("") }
      it "prints errors to stderr and rejects commit" do
        assert_equal FitCommit::Runner::EXIT_CODE_REJECT_COMMIT, call_runner
        assert_error_output(interactive: false)
      end
    end
  end
end
