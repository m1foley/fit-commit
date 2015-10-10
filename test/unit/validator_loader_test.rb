require "test_helper"
require "fit_commit/validator_loader"
Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }

describe FitCommit::ValidatorLoader do
  let(:validators) { loader.validators }
  let(:loader) { FitCommit::ValidatorLoader.new(branch_name, configuration) }
  let(:branch_name) { "foo" }
  let(:configuration) do
    # Starting with all disabled because every validator needs at least a
    # default entry.
    # The ones specified here are the ones we care about testing.
    all_disabled_configuration.merge(
      FitCommit::Validators::LineLength.name => { "Enabled" => false },
      FitCommit::Validators::Wip.name => { "Enabled" => true },
      FitCommit::Validators::Frathouse.name => { "Enabled" => ["bar", /\Abaz+/] }
    )
  end
  let(:all_disabled_configuration) do
    FitCommit::Validators::Base.all.each_with_object({}) do |v, config|
      config[v.name] = { "Enabled" => false }
    end
  end

  it "loads enabled validators" do
    assert validators.one? { |v| v.is_a? FitCommit::Validators::Wip }
  end

  it "doesn't load disabled validators" do
    assert validators.none? { |v| v.is_a? FitCommit::Validators::LineLength }
  end

  describe "non-boolean options for Enabled" do
    describe "branch_name does not match validator" do
      it "doesn't load validator" do
        assert validators.none? { |v| v.is_a? FitCommit::Validators::Frathouse }
      end
    end

    describe "branch_name matches validator via String" do
      let(:branch_name) { "bar" }
      it "loads validator" do
        assert validators.one? { |v| v.is_a? FitCommit::Validators::Frathouse }
      end
    end

    describe "branch_name matches validator via regex" do
      let(:branch_name) { "bazzz" }
      it "loads validator" do
        assert validators.one? { |v| v.is_a? FitCommit::Validators::Frathouse }
      end
    end
  end

  describe "branch_name is blank" do
    let(:branch_name) { "" }
    it "loads enabled validators" do
      assert validators.one? { |v| v.is_a? FitCommit::Validators::Wip }
    end
    it "doesn't load disabled validators" do
      assert validators.none? { |v| v.is_a? FitCommit::Validators::LineLength }
    end
    it "doesn't load validators that have non-boolean options for Enabled" do
      assert validators.none? { |v| v.is_a? FitCommit::Validators::Frathouse }
    end
  end

  describe "custom validators required" do
    after do
      custom_validator_file.unlink
    end

    let(:custom_validator_file) do
      create_tempfile(["my_custom_validator", ".rb"], custom_validator_code)
    end

    # Not actually subclassing FitCommit::Validators::Base because
    # that affects the loaded validators for other tests.
    let(:custom_validator_code) do
      <<-EOF
        class MyCustomValidator
          attr_accessor :config
          def initialize(_branch_name, config)
            self.config = config
          end
          def enabled?
            config.fetch("Enabled")
          end
        end
      EOF
    end

    let(:configuration) do
      all_disabled_configuration.merge(
        "FitCommit" => { "Require" => [custom_validator_file.path] },
        "MyCustomValidator" => { "Enabled" => true }
      )
    end

    it "loads enabled custom validator" do
      # stub which will be overridden when the custom validator file is loaded
      MyCustomValidator = Class.new

      FitCommit::Validators::Base.stub(:all, [MyCustomValidator]) do
        assert_equal 1, validators.size
        assert validators.first.is_a?(MyCustomValidator)
      end
    end
  end
end
