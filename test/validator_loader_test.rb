require "minitest/autorun"
require "fit_commit/validator_loader"
Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }

describe FitCommit::ValidatorLoader do
  let(:validators) { loader.validators }
  let(:loader) { FitCommit::ValidatorLoader.new(branch_name, configuration) }
  let(:branch_name) { "foo" }
  let(:configuration) do
    {
      "FitCommit::Validators::LineLength" => { "Enabled" => false },
      "FitCommit::Validators::Tense" => { "Enabled" => false },
      "FitCommit::Validators::SummaryPeriod" => { "Enabled" => true },
      "FitCommit::Validators::Wip" => { "Enabled" => true },
      "FitCommit::Validators::Frathouse" => { "Enabled" => ["bar", /\Abaz+/] }
    }
  end

  it "loads enabled validators" do
    assert validators.any? { |v| v.is_a? FitCommit::Validators::SummaryPeriod }
    assert validators.any? { |v| v.is_a? FitCommit::Validators::Wip }
  end

  it "doesn't load disabled validators" do
    assert validators.none? { |v| v.is_a? FitCommit::Validators::LineLength }
    assert validators.none? { |v| v.is_a? FitCommit::Validators::Tense }
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
