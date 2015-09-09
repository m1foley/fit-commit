require "fit_commit/configuration_loader"

module FitCommit
  class ValidatorLoader
    attr_accessor :branch_name, :configuration
    def initialize(branch_name, configuration = load_configuration)
      self.branch_name = branch_name
      self.configuration = configuration
    end

    def validators
      all_validators.select(&:enabled?)
    end

    private

    def load_configuration
      FitCommit::ConfigurationLoader.new.global_configuration
    end

    def all_validators
      Dir[File.dirname(__FILE__) + "/validators/*.rb"].each { |file| require file }
      FitCommit::Validators::Base.all.map do |validator_class|
        validator_class.new(branch_name, config_for(validator_class))
      end
    end

    def config_for(validator_class)
      configuration[validator_class.name] || {}
    end
  end
end
