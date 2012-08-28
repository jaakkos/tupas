# -*- encoding : utf-8 -*-
module Tupas
  class Configuration
    include Singleton
    attr_reader :_settings

    def initialize
      @_settings = {}
      @_settings = @_settings.deep_merge!(settings_yaml('config/tupas.yml')[Tupas.env]).with_indifferent_access
      self
    end

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = "tupas"
      logger
    end

    def settings_yaml(file)
      YAML.load(File.open(File.join(Tupas.root, file)))
    end

    def method_missing(name, *args, &block)
      @_settings[name.to_sym] ||
      fail(NoMethodError, "unknown configuration root #{name}", caller)
    end
  end
end
