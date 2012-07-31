module Tupas
  class Configuration
    include Singleton
    attr_reader :_settings
    @_settings = {}

    def initialize
      @_settings = {}
      _settings = load_settings_yaml('config/tupas.yml')
      _settings.each_pair{|key, value| @_settings = Utils.deep_merge(@_settings, { key.to_sym => value }) }
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
