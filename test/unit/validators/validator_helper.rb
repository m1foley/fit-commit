require "minitest/autorun"
require "yaml"

def default_config_for(key)
  YAML.load_file(
    File.expand_path("../../../../templates/config/fit_commit.default.yml", __FILE__)).
    fetch(key)
end
