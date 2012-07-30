module Tupas
  class Configuration
    include Singleton
    attr_reader :_settings

    @@defaults = {
      config_files: {
        message_default_settings: 'config/default_settings.yml',
        message_service_providers: 'config/service_providers.yml'
      }
    }

    def self.defaults
      @@defaults
    end

    def initialize
      @_settings = {}
      @@defaults[:config_files].each_pair do |key, value|
        @_settings = Utils.deep_merge(@_settings, { key => load_settings_yaml(value) })
      end
    end

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = "tupas"
      logger
    end

    def load_settings_yaml(file)
      YAML.load(File.open(File.join(Tupas::Utils.root_path, file)))
    end

    def method_missing(name, *args, &block)
      @_settings[name.to_sym] ||
      fail(NoMethodError, "unknown configuration root #{name}", caller)
    end
  end
end
