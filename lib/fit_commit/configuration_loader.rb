require "yaml"

module FitCommit
  class ConfigurationLoader
    SYSTEM_FILEPATH = "/etc/fit_commit.yml"
    LOCAL_FILEPATH = ".fit_commit.yml"

    def initialize(filepaths)
      self.filepaths = filepaths
    end

    def self.default_configuration
      new(default_filepaths).configuration
    end

    def configuration
      filepaths.each_with_object({}) do |filepath, config|
        config.merge!(read_config(filepath)) do |_key, oldval, newval|
          oldval.merge(newval)
        end
      end
    end

    def self.default_filepaths
      [
        gem_default_filepath,
        SYSTEM_FILEPATH,
        user_filepath,
        config_filepath,
        LOCAL_FILEPATH
      ]
    end

    def self.gem_default_filepath
      File.expand_path("../../../templates/config/fit_commit.default.yml", __FILE__)
    end

    def self.user_filepath
      File.join(ENV["HOME"], ".fit_commit.yml")
    end

    def self.config_filepath
      File.join(git_top_level, "config", "fit_commit.yml")
    end

    def self.git_top_level
      top_level = `git rev-parse --show-toplevel`.chomp.strip
      fail "Git repo not found! Please submit a bug report." if top_level == ""
      top_level
    end

    private

    # sorted by increasing precedence
    attr_accessor :filepaths

    def read_config(path)
      load_yaml(path).each_with_object({}) do |(key, value), config|
        translated_key = translate_config_key(key)
        config[translated_key] = value
      end
    end

    def load_yaml(path)
      content = YAML.load_file(path) if File.readable?(path)
      content || {}
    rescue => e
      raise e, "Error parsing config file: #{e.message}"
    end

    def translate_config_key(config_key)
      return config_key unless config_key.include?("/")
      "FitCommit::" + config_key.gsub("/", "::")
    end
  end
end
