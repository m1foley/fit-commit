require "minitest/autorun"
require "fit_commit/configuration_loader"

describe FitCommit::ConfigurationLoader do
  subject { FitCommit::ConfigurationLoader.new }

  after do
    [system_file, user_file].compact.each(&:unlink)
  end

  let(:global_configuration) do
    subject.stub :default_filepath, "nofile" do
      subject.stub :system_filepath, (system_file ? system_file.path : "nofile") do
        subject.stub :user_filepath, (user_file ? user_file.path : "nofile") do
          subject.stub :config_filepath, "nofile" do
            subject.stub :local_filepath, "nofile" do
              subject.stub :git_top_level, "." do
                subject.global_configuration
              end
            end
          end
        end
      end
    end
  end

  def tempfile(filename, content)
    Tempfile.new(filename).tap do |f|
      f.write(content)
      f.close
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
    let(:user_file) { tempfile("user_file", user_file_content) }
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
  end

  describe "multiple configuration files present" do
    let(:system_file) { tempfile("system_file", system_file_content) }
    let(:user_file) { tempfile("user_file", user_file_content) }
    let(:system_file_content) do
      "Foo/Bar:\n  Baz: false\nQux/Norf/Blah:\n  - !ruby/regexp /\\Afoo/"
    end
    let(:user_file_content) do
      "Qux/Norf/Blah:\n  Foobar: true\nBuz:\n  - hi"
    end

    it "is a merged configuration that takes precedence into account" do
      expected = {
        "FitCommit::Foo::Bar" => { "Baz" => false },
        "FitCommit::Qux::Norf::Blah" => { "Foobar" => true },
        "FitCommit::Buz" => ["hi"]
      }
      assert_equal expected, global_configuration
    end
  end
end
