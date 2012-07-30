module Tupas
  class Rack < ::Rack::Builder
    def initialize(app, &block)
      super
    end

    def call(env)
      # Add here
    end

    def configure(&block)
      Tupas.configure(&block)
    end

    def self.logger
      config.logger
    end

    def options(options = false)
      return @options || {} if options == false
      @options = options
    end

  end
end