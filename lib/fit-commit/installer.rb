require "fileutils"

module FitCommit
  class Installer
    HOOK_TEMPLATE_PATH = File.expand_path("../../../templates/hooks/commit-msg", __FILE__)

    def install
      FileUtils.mkdir_p(File.dirname(hook_path))
      FileUtils.cp(HOOK_TEMPLATE_PATH, hook_path)
      FileUtils.chmod(0755, hook_path)
      $stdout.puts "Installed hook to #{hook_path}"
      true
    end

    def uninstall
      if delete_hook
        $stdout.puts "Deleted hook at #{hook_path}"
      else
        $stdout.puts "Hook not found at #{hook_path}"
      end
      true
    end

    private

    def hook_path
      @hook_path ||= File.join(gitdir, "hooks/commit-msg")
    end

    def gitdir
      if File.directory?(".git")
        ".git"
      else
        File.readlines(".git").first.match(/gitdir: (.*)$/)[1]
      end
    end

    def delete_hook
      deleted_count = File.delete(hook_path)
      deleted_count > 0
    rescue Errno::ENOENT
      false
    end
  end
end
