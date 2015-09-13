require "minitest/autorun"
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
    assert validators.any? { |v| v.is_a? FitCommit::Validators::Wip }
  end

  it "doesn't load disabled validators" do
    assert validators.none? { |v| v.is_a? FitCommit::Validators::LineLength }
  end

  describe "non-boolean options for Enabled" do
    it "doesn't load validators with a non-matching string/regex Enabled values" do
      assert validators.none? { |v| v.is_a? FitCommit::Validators::Frathouse }
    end

    describe "validator has a matching string Enabled value" do
      let(:branch_name) { "bar" }
      it "loads validator" do
        assert validators.any? { |v| v.is_a? FitCommit::Validators::Frathouse }
      end
    end

    describe "validator has a matching regex Enabled value" do
      let(:branch_name) { "bazzz" }
      it "loads validator" do
        assert validators.any? { |v| v.is_a? FitCommit::Validators::Frathouse }
      end
    end
  end
end
