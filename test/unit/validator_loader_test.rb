require "test_helper"
require "fit_commit/validator_loader"
Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }

describe FitCommit::ValidatorLoader do
  def simple_validators(branch_name: "mybranch")
    # Starting with all disabled because every validator needs at least a
    # default entry.
    # The ones specified here are the ones we care about testing.
    configuration = all_disabled_configuration.merge(
      FitCommit::Validators::LineLength.name => { "Enabled" => false },
      FitCommit::Validators::Wip.name => { "Enabled" => true },
      FitCommit::Validators::Frathouse.name => { "Enabled" => ["bar", /\Abaz+/] }
    )
    FitCommit::ValidatorLoader.new(branch_name, configuration).validators
  end

  def all_disabled_configuration
    FitCommit::Validators::Base.all.each_with_object({}) do |v, config|
      config[v.name] = { "Enabled" => false }
    end
  end

  it "loads enabled validators" do
    assert simple_validators.grep(FitCommit::Validators::Wip).one?
  end

  it "doesn't load disabled validators" do
    assert simple_validators.grep(FitCommit::Validators::LineLength).none?
  end

  describe "non-boolean options for Enabled" do
    describe "branch_name does not match validator" do
      it "doesn't load validator" do
        assert simple_validators.grep(FitCommit::Validators::Frathouse).none?
      end
    end

    describe "branch_name matches validator via String" do
      it "loads validator" do
        assert simple_validators(branch_name: "bar").
          grep(FitCommit::Validators::Frathouse).one?
      end
    end

    describe "branch_name matches validator via regex" do
      it "loads validator" do
        assert simple_validators(branch_name: "bazzz").
          grep(FitCommit::Validators::Frathouse).one?
      end
    end
  end

  describe "branch_name is blank" do
    it "loads enabled validators" do
      assert simple_validators(branch_name: "").grep(FitCommit::Validators::Wip).one?
    end
    it "doesn't load disabled validators" do
      assert simple_validators(branch_name: "").grep(FitCommit::Validators::LineLength).none?
    end
    it "doesn't load validators that have non-boolean options for Enabled" do
      assert simple_validators(branch_name: "").grep(FitCommit::Validators::Frathouse).none?
    end
  end

  describe "custom validators required" do
    it "loads enabled custom validator" do
      # Not actually subclassing FitCommit::Validators::Base because
      # that affects the loaded validators for other tests.
      custom_validator_code = <<~EOF
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

      # rb extension is necessary to `require` it
      custom_validator_file = create_tempfile(
        custom_validator_code, ["custom_validator", ".rb"])

      configuration = all_disabled_configuration.merge(
        "FitCommit" => { "Require" => [custom_validator_file.path] },
        "MyCustomValidator" => { "Enabled" => true }
      )

      # stub which will be overridden when the custom validator file is loaded
      MyCustomValidator = Class.new

      validators = FitCommit::Validators::Base.stub(:all, [MyCustomValidator]) do
        FitCommit::ValidatorLoader.new("mybranch", configuration).validators
      end
      assert_equal 1, validators.size
      assert validators.first.is_a?(MyCustomValidator)
    end
  end
end
