require "test_helper"
require "fit_commit/runner"

describe FitCommit::Runner do
  let(:commit_msg_file_path) { create_tempfile(commit_msg).path }
  let(:stderr) { StringIO.new }
  let(:stdin) { StringIO.new }
  let(:branch_name) { "any" }
  let(:runner) do
    FitCommit::Runner.new(commit_msg_file_path, branch_name, stderr, stdin)
  end

  def call_runner
    exit_code = runner.run
    stderr.rewind
    exit_code
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

    def assert_error_output(interactive: true, includes_edit: false)
      stderr_lines = stderr.read.lines.map(&:chomp)
      if interactive
        if includes_edit
          assert_equal 13, stderr_lines.size
        else
          assert_equal 8, stderr_lines.size
        end
      else
        assert_equal 6, stderr_lines.size
      end
      assert_equal commit_msg, stderr_lines[0..1].join("\n")
      assert_empty stderr_lines[2]
      assert_match(/\A1: Error: /, stderr_lines[3])
      assert_match(/\A1: Error: /, stderr_lines[4])
      assert_match(/\A2: Error: /, stderr_lines[5])
      if interactive
        assert_empty stderr_lines[6]
        assert_match(/\ACommit anyway\? \[y\/n\/e\] /, stderr_lines[7])
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
      describe "empty branch name" do
        let(:branch_name) { "" }
        it "prints errors to stderr and rejects commit" do
          assert_equal FitCommit::Runner::EXIT_CODE_REJECT_COMMIT, call_runner
          assert_error_output
        end
      end
    end
    describe "user forces commit" do
      let(:stdin) { fake_tty("y") }
      it "prints errors to stderr and allows commit" do
        assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
        assert_error_output
      end
    end
    describe "user edits commit" do
      let(:stdin) { fake_tty("e") }
      describe "editor fails to save" do
        it "rejects commit" do
          def runner.edit_message
            nil # fail code
          end
          assert_equal FitCommit::Runner::EXIT_CODE_REJECT_COMMIT, call_runner
          assert_error_output
        end
      end
      describe "edited message is valid" do
        before do
          def runner.edit_message
            File.open(message_path, "w") do |f|
              f.print "Valid message"
            end
            :success_code
          end
        end
        it "allows commit" do
          assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
          assert_error_output
        end
      end
      describe "edited message is invalid" do
        before do
          def runner.edit_message
            File.open(message_path, "w") do |f|
              f.print "invalid message."
            end
            :success_code
          end
        end
        describe "user forces second commit" do
          let(:stdin) { fake_tty("e\ny") }
          it "asks again and accepts commit" do
            assert_equal FitCommit::Runner::EXIT_CODE_ALLOW_COMMIT, call_runner
            assert_error_output(includes_edit: true)
          end
        end
        describe "user doesn't force second commit" do
          let(:stdin) { fake_tty("e\nn") }
          it "asks again and rejects commit" do
            assert_equal FitCommit::Runner::EXIT_CODE_REJECT_COMMIT, call_runner
            assert_error_output(includes_edit: true)
          end
        end
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
