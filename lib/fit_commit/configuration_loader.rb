require "yaml"

module FitCommit
  class ConfigurationLoader
    def global_configuration
      all_filepaths.each_with_object({}) do |filepath, config|
        config.merge!(read_config(filepath)) do |_key, oldval, newval|
          oldval.merge(newval)
        end
      end
    end

    private

    def all_filepaths
      # sorted by increasing precedence
      [default_filepath, system_filepath, user_filepath, config_filepath, local_filepath]
    end

    def default_filepath
      File.expand_path("../../../templates/config/fit_commit.default.yml", __FILE__)
    end

    def system_filepath
      "/etc/fit_commit.yml"
    end

    def user_filepath
      File.join(ENV["HOME"], ".fit_commit.yml")
    end

    def config_filepath
      File.join(git_top_level, "config", "fit_commit.yml")
    end

    def local_filepath
      ".fit_commit.yml"
    end

    def git_top_level
      top_level = `git rev-parse --show-toplevel`.chomp.strip
      fail "Git repo not found! Please submit a bug report." if top_level == ""
      top_level
    end

    def read_config(path)
      load_yaml(path).each_with_object({}) do |(key, value), config|
        translated_key = translate_class_name(key)
        config[translated_key] = value
      end
    end

    def load_yaml(path)
      content = YAML.load_file(path) if File.exist?(path)
      content || {}
    rescue => e
      raise e, "Error parsing config file: #{e.message}"
    end

    def translate_class_name(config_class_name)
      "FitCommit::" + config_class_name.gsub("/", "::")
    end
  end
end
