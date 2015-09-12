require "minitest/autorun"
require "pty"
require "expect"

describe "Install and run in a fresh Git repo" do
  BINARY_PATH = File.expand_path("../../../bin/fit-commit", __FILE__)

  it "installs with no errors" do
    Dir.mktmpdir do |gitdir|
      results = ""
      commands = "cd #{gitdir} && git init && #{BINARY_PATH} install && git commit --allow-empty -m fixing"
      PTY.spawn(commands) do |pty_out, _pty_in, _pty_pid|
        pty_out.expect(/Force commit\?/, 3) do |expect_out|
          results << Array(expect_out).join
          "n"
        end
      end
      assert_match(/^fixing/, results)
      assert_match(/^1: Error: Message must use imperative present tense/, results)
    end
  end
end
