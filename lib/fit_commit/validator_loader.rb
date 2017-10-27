require "fit_commit/configuration_loader"

module FitCommit
  class ValidatorLoader
    def initialize(branch_name, configuration = load_configuration)
      self.branch_name = branch_name
      self.configuration = configuration
    end

    def validators
      all_validators.select(&:enabled?)
    end

    private

    attr_accessor :branch_name, :configuration

    def load_configuration
      FitCommit::ConfigurationLoader.default_configuration
    end

    def all_validators
      require_all_validators
      FitCommit::Validators::Base.all.map do |validator_class|
        validator_class.new(branch_name, config_for(validator_class))
      end
    end

    def require_all_validators
      paths = Dir[File.dirname(__FILE__) + "/validators/*.rb"] + custom_requires
      paths.each { |file| require file }
    end

    def custom_requires
      Array(global_settings["Require"])
    end

    def global_settings
      configuration["FitCommit"] || {}
    end

    def config_for(validator_class)
      configuration[validator_class.name] || {}
    end
  end
end
