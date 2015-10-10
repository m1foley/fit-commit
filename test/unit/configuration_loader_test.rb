require "test_helper"
require "fit_commit/configuration_loader"

describe FitCommit::ConfigurationLoader do
  subject { FitCommit::ConfigurationLoader.new }

  after do
    [system_file, user_file].compact.each(&:unlink)
  end

  let(:global_configuration) do
    subject.stub :default_filepath, "/dev/null" do
      subject.stub :system_filepath, (system_file ? system_file.path : "/dev/null") do
        subject.stub :user_filepath, (user_file ? user_file.path : "/dev/null") do
          subject.stub :config_filepath, "/dev/null" do
            subject.stub :local_filepath, "/dev/null" do
              subject.stub :git_top_level, "." do
                subject.global_configuration
              end
            end
          end
        end
      end
    end
  end

  describe "no configuration files present" do
    let(:system_file) { nil }
    let(:user_file) { nil }
    it "is empty" do
      assert_equal({}, global_configuration)
    end
  end

  describe "just one configuration file present" do
    let(:system_file) { nil }
    let(:user_file) { create_tempfile("user_file", user_file_content) }
    let(:user_file_content) do
      "Foo/Bar:\n  Baz: false\nQux/Norf/Blah:\n  - !ruby/regexp /\\Afoo/"
    end

    it "is a configuration equal to that file" do
      expected = {
        "FitCommit::Foo::Bar" => { "Baz" => false },
        "FitCommit::Qux::Norf::Blah" => [/\Afoo/]
      }
      assert_equal expected, global_configuration
    end

    describe "has a non-validation key" do
      let(:user_file_content) do
        "FitCommit:\n  Require:\n    - foo/bar"
      end
      it "doesn't try to namespace the key" do
        expected = {
          "FitCommit" => { "Require" => ["foo/bar"] }
        }
        assert_equal expected, global_configuration
      end
    end
  end

  describe "multiple configuration files present" do
    let(:system_file) { create_tempfile("system_file", system_file_content) }
    let(:user_file) { create_tempfile("user_file", user_file_content) }
    let(:system_file_content) do
      "Foo/Bar:\n  Baz: false\nQux/Norf/Blah:\n  Foobar:\n    - !ruby/regexp /\\Afoo/\n  Booyah: false"
    end
    let(:user_file_content) do
      "Qux/Norf/Blah:\n  Foobar: true\nAbc/Buz:\n  - hi"
    end

    it "is a merged configuration that takes precedence into account" do
      expected = {
        "FitCommit::Foo::Bar" => { "Baz" => false },
        "FitCommit::Qux::Norf::Blah" => { "Foobar" => true, "Booyah" => false },
        "FitCommit::Abc::Buz" => ["hi"]
      }
      assert_equal expected, global_configuration
    end
  end
end
