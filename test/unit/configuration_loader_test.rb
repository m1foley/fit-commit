require "test_helper"
require "fit_commit/configuration_loader"

describe FitCommit::ConfigurationLoader do
  describe "no configuration files present" do
    it "is empty" do
      config = FitCommit::ConfigurationLoader.new(["/dev/null"]).configuration
      assert_equal({}, config)
    end
  end

  describe "just one configuration file present" do
    it "is a configuration equal to that file" do
      config_content = <<~EOF
        Foo/Bar:
          Baz: false
        Qux/Norf/Blah:
          - !ruby/regexp /\\Afoo/
      EOF
      config_file_path = create_tempfile(config_content).path

      expected_config = {
        "FitCommit::Foo::Bar" => { "Baz" => false },
        "FitCommit::Qux::Norf::Blah" => [/\Afoo/]
      }

      config = FitCommit::ConfigurationLoader.new([config_file_path]).configuration
      assert_equal expected_config, config
    end

    describe "has a key without a slash" do
      it "doesn't try to namespace the key" do
        config_content = <<~EOF
        FitCommit:
          Require:
            - foo/bar
        EOF
        config_file_path = create_tempfile(config_content).path

        expected_config = {
          "FitCommit" => { "Require" => ["foo/bar"] }
        }

        config = FitCommit::ConfigurationLoader.new([config_file_path]).configuration
        assert_equal expected_config, config
      end
    end
  end

  describe "multiple configuration files present" do
    it "is a merged configuration that takes precedence into account" do
      config1_content = <<~EOF
        Foo/Bar:
          Baz: false
        Qux/Norf/Blah:
          Foobar:
            - !ruby/regexp /\\Afoo/
          Booyah: false
      EOF

      config2_content = <<~EOF
        Qux/Norf/Blah:
          Foobar: true
        Abc/Buz:
          - hi
      EOF

      config_file_paths = [
        create_tempfile(config1_content).path,
        create_tempfile(config2_content).path
      ]

      expected_config = {
        "FitCommit::Foo::Bar" => { "Baz" => false },
        "FitCommit::Qux::Norf::Blah" => { "Foobar" => true, "Booyah" => false },
        "FitCommit::Abc::Buz" => ["hi"]
      }

      config = FitCommit::ConfigurationLoader.new(config_file_paths).configuration
      assert_equal expected_config, config
    end
  end

  describe "default_configuration" do
    it "loads configuration from default filepaths" do
      config_content = <<~EOF
        FitCommit:
          Require:
            - foo/bar
      EOF
      config_file_path = create_tempfile(config_content).path

      expected_config = {
        "FitCommit" => { "Require" => ["foo/bar"] }
      }

      config = FitCommit::ConfigurationLoader.stub(:default_filepaths, [config_file_path]) do
        FitCommit::ConfigurationLoader.default_configuration
      end
      assert_equal expected_config, config
    end
  end

  describe "gem_default_filepath" do
    it "returns a valid filepath" do
      gem_default_filepath = FitCommit::ConfigurationLoader.gem_default_filepath
      assert File.exist?(gem_default_filepath)
    end
  end
end
