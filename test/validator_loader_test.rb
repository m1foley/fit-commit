require "minitest/autorun"
require "fit_commit/validator_loader"
Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }

describe FitCommit::ValidatorLoader do
  let(:validators) { loader.validators }
  let(:loader) { FitCommit::ValidatorLoader.new(branch_name, configuration) }
  let(:branch_name) { "foo" }
  let(:configuration) do
    {
      "FitCommit::Validators::SummaryPeriod" => { "Enabled" => true },
      "FitCommit::Validators::Tense" => { "Enabled" => false },
      "FitCommit::Validators::Wip" => nil
      # "FitCommit::Validators::LineLength" => (not in config)
    }
  end

  it "loads explicitly enabled validators" do
    assert validators.any? { |v| v.is_a? FitCommit::Validators::SummaryPeriod }
  end

  it "loads validators not mentioned in configuration" do
    assert validators.any? { |v| v.is_a? FitCommit::Validators::LineLength }
  end

  it "doesn't load disabled validators" do
    assert validators.none? { |v| v.is_a? FitCommit::Validators::Tense }
  end

  it "loads validators that have an empty config for some reason" do
    assert validators.any? { |v| v.is_a? FitCommit::Validators::Wip }
  end
end
