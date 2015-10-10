require "test_helper"
require "pty"
require "expect"

describe "Install and run in a fresh Git repo" do
  BINARY_PATH = File.expand_path("../../../bin/fit-commit", __FILE__)

  def shell_commands(gitdir)
    "cd #{gitdir} && git init && #{BINARY_PATH} install && git commit --allow-empty -m '#{commit_message}'"
  end

  let(:results) do
    output = ""
    Dir.mktmpdir do |gitdir|
      PTY.spawn(shell_commands(gitdir)) do |pty_out, _pty_in, _pty_pid|
        if user_input
          pty_out.expect(/Force commit\?/, 3) do |expect_out|
            output << Array(expect_out).join
            user_input
          end
        else
          output << pty_out.read
        end
      end
    end
    output
  end

  describe "invalid commit message" do
    let(:commit_message) { "fixing foo" }
    let(:user_input) { "n" }
    it "disallows commit" do
      assert_match(/^#{commit_message}/, results)
      assert_match(/^1: Error: /, results)
      refute_match(/Warning:/, results)
      refute_match(/^\[master .+\]/, results)
    end
  end

  describe "valid commit message" do
    let(:commit_message) { "Fix foo" }
    let(:user_input) { nil }
    it "allows commit" do
      refute_match(/^#{commit_message}/, results)
      refute_match(/Error:/, results)
      refute_match(/Warning:/, results)
      assert_match(/^\[master .+\] #{commit_message}/, results)
    end
  end

  describe "commit message with warning only" do
    let(:commit_message) { "X" * 51 }
    let(:user_input) { nil }
    it "allows commit" do
      refute_match(/^#{commit_message}/, results)
      refute_match(/Error/, results)
      assert_match(/^1: Warning: /, results)
      assert_match(/^\[master .+\] #{commit_message}/, results)
    end
  end
end
